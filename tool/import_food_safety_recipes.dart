import 'dart:convert';
import 'dart:io';

const _serviceId = 'COOKRCP01';
const _defaultOutputPath = 'assets/data/open_recipes_seed.json';

Future<void> main(List<String> args) async {
  final apiKey = Platform.environment['FOODSAFETY_API_KEY']?.trim();
  final outputPath = _argValue(args, '--out') ?? _defaultOutputPath;
  final limit = int.tryParse(_argValue(args, '--limit') ?? '') ?? 80;
  final useSample = apiKey == null || apiKey.isEmpty;
  final key = useSample ? 'sample' : apiKey;

  final recipes = <Map<String, dynamic>>[];
  var start = 1;
  const pageSize = 100;
  var totalCount = limit;

  while (recipes.length < limit && start <= totalCount) {
    final end = (start + pageSize - 1).clamp(start, limit);
    final uri = Uri.parse(
      'http://openapi.foodsafetykorea.go.kr/api/$key/$_serviceId/json/$start/$end',
    );
    final payload = await _fetchJson(uri);
    final root = payload[_serviceId] as Map<String, dynamic>? ?? const {};
    totalCount =
        int.tryParse(root['total_count']?.toString() ?? '') ?? totalCount;
    final rows = (root['row'] as List? ?? const [])
        .whereType<Map<String, dynamic>>();

    for (final row in rows) {
      final recipe = _mapFoodSafetyRecipe(row);
      if (recipe != null) recipes.add(recipe);
    }

    if (useSample) break;
    start += pageSize;
  }

  final file = File(outputPath);
  await file.parent.create(recursive: true);
  const encoder = JsonEncoder.withIndent('  ');
  await file.writeAsString('${encoder.convert(recipes)}\n');

  stdout.writeln(
    'Wrote ${recipes.length} recipes to $outputPath '
    '(${useSample ? 'sample endpoint' : 'authorized endpoint'}).',
  );
}

Map<String, dynamic>? _mapFoodSafetyRecipe(Map<String, dynamic> row) {
  final title = _clean(row['RCP_NM']);
  final parts = _clean(row['RCP_PARTS_DTLS']);
  final steps = [
    for (var i = 1; i <= 20; i++)
      _clean(row['MANUAL${i.toString().padLeft(2, '0')}']),
  ].where((step) => step.isNotEmpty).toList();

  if (title.isEmpty || parts.isEmpty || steps.isEmpty) return null;

  final ingredients = _extractIngredients(parts, title);
  final category = _clean(row['RCP_PAT2']);
  final method = _clean(row['RCP_WAY2']);
  final calories = double.tryParse(_clean(row['INFO_ENG']))?.round();
  final imageUrl = _clean(row['ATT_FILE_NO_MAIN']).isNotEmpty
      ? _clean(row['ATT_FILE_NO_MAIN'])
      : _clean(row['ATT_FILE_NO_MK']);

  return {
    'title': title,
    'reason': _reasonFor(category, method, calories),
    'time': _estimatedTime(method, category),
    'difficulty': _difficultyFor(steps.length),
    'budget': _estimatedBudget(ingredients, category),
    'imageUrl': imageUrl,
    'ingredients': ingredients,
    'steps': steps,
    'relatedDealIds': const <String>[],
    'tag': category.isNotEmpty ? category : '공공 레시피',
    'source': '식품의약품안전처 조리식품의 레시피 DB',
    'sourceRecipeId': _clean(row['RCP_SEQ']),
    'license': '공공누리 제1유형: 출처표시, 상업적 이용 가능, 변경 가능',
    'calories': calories,
    'rawIngredients': parts,
    'nutrition': {
      'carbohydrate': _clean(row['INFO_CAR']),
      'protein': _clean(row['INFO_PRO']),
      'fat': _clean(row['INFO_FAT']),
      'sodium': _clean(row['INFO_NA']),
    },
  };
}

Future<Map<String, dynamic>> _fetchJson(Uri uri) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(uri);
    final response = await request.close();
    final body = await utf8.decodeStream(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException('HTTP ${response.statusCode}: $body', uri: uri);
    }
    return jsonDecode(body) as Map<String, dynamic>;
  } finally {
    client.close(force: true);
  }
}

List<String> _extractIngredients(String raw, String title) {
  final normalized = raw
      .replaceAll(RegExp(r'[\[\]●·ㆍ:：]'), ' ')
      .replaceAll(RegExp(r'\([^)]*\)'), ' ')
      .replaceAll(
        RegExp(
          r'[0-9]+(?:\.[0-9]+)?\s*(?:g|ml|kg|L|개|큰술|작은술|컵|쪽|마리|장|줄기|봉지|모|알|cm|분의\s*\d+)?',
        ),
        ' ',
      )
      .replaceAll(RegExp(r'\s+'), ' ');

  final stopWords = {
    '주재료',
    '재료',
    '양념',
    '양념장',
    '소스',
    '고명',
    '장식',
    '다진',
    '소박이',
    '오이무침',
    '북엇국',
    '새우두부계란찜',
    '순두부사과',
    title,
    title.replaceAll(' ', ''),
    '물',
    '약간',
    '주',
    '부',
    '분',
    '인분',
  };
  final candidates = normalized
      .split(RegExp(r'[,/\n]|\s{2,}'))
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .expand((part) => part.split(' '))
      .map((part) => part.trim())
      .where((part) => part.length >= 2)
      .where((part) => !stopWords.contains(part))
      .map(_canonicalIngredient)
      .where((part) => part.isNotEmpty)
      .toSet()
      .toList();

  candidates.sort();
  return candidates.take(12).toList();
}

String _canonicalIngredient(String value) {
  final cleaned = value
      .replaceAll(RegExp(r'[^\uAC00-\uD7A3a-zA-Z]'), '')
      .replaceAll('저염', '')
      .trim();
  const aliases = {
    '달걀': '계란',
    '계란': '계란',
    '대파': '대파',
    '파': '대파',
    '다진마늘': '다진마늘',
    '마늘': '다진마늘',
    '저염간장': '간장',
    '간장': '간장',
    '무염버터': '버터',
    '올리브유': '식용유',
    '요리당': '설탕',
    '조선부추': '부추',
  };
  return aliases[cleaned] ?? cleaned;
}

String _reasonFor(String category, String method, int? calories) {
  final fragments = [
    if (category.isNotEmpty) category,
    if (method.isNotEmpty) method,
    if (calories != null) '${calories}kcal',
  ];
  if (fragments.isEmpty) return '공공 레시피 DB에서 가져온 추천 메뉴';
  return '공공 레시피 · ${fragments.join(' · ')}';
}

String _estimatedTime(String method, String category) {
  if (method.contains('기타')) return '15분';
  if (method.contains('굽') || method.contains('볶')) return '20분';
  if (method.contains('찌') || method.contains('끓')) return '25분';
  if (category.contains('후식')) return '10분';
  return '20분';
}

String _difficultyFor(int stepCount) {
  if (stepCount <= 3) return '쉬움';
  if (stepCount <= 6) return '보통';
  return '손이 감';
}

int _estimatedBudget(List<String> ingredients, String category) {
  final base = category.contains('후식') ? 4500 : 5200;
  return base + ingredients.length.clamp(3, 10) * 350;
}

String _clean(Object? value) =>
    value?.toString().replaceAll(RegExp(r'\s+'), ' ').trim() ?? '';

String? _argValue(List<String> args, String name) {
  final index = args.indexOf(name);
  if (index == -1 || index + 1 >= args.length) return null;
  return args[index + 1];
}
