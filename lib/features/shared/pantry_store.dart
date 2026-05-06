import 'package:flutter/foundation.dart';

class PantryStore extends ChangeNotifier {
  PantryStore._();

  static final PantryStore instance = PantryStore._();

  static const availableIngredients = [
    '소금',
    '설탕',
    '식용유',
    '간장',
    '고춧가루',
    '고추장',
    '된장',
    '참기름',
    '다진마늘',
    '양파',
    '대파',
    '계란',
    '밥',
    '감자',
    '당근',
    '카레가루',
    '김치',
    '두부',
    '콩나물',
    '돼지고기',
    '닭가슴살',
    '참치',
    '라면',
    '만두',
    '밀가루',
    '우유',
    '요거트',
    '사과',
    '샐러드채소',
  ];

  final Set<String> _selected = {'소금', '식용유', '고춧가루', '양파'};

  Set<String> get selected => Set.unmodifiable(_selected);

  bool contains(String ingredient) => _selected.contains(ingredient);

  int matchCount(Iterable<String> ingredients) {
    return ingredients.where(_selected.contains).length;
  }

  List<String> missingIngredients(Iterable<String> ingredients) {
    return ingredients.where((item) => !_selected.contains(item)).toList();
  }

  void toggle(String ingredient) {
    if (_selected.contains(ingredient)) {
      _selected.remove(ingredient);
    } else {
      _selected.add(ingredient);
    }
    notifyListeners();
  }

  void add(String ingredient) {
    final value = ingredient.trim();
    if (value.isEmpty) return;
    _selected.add(value);
    notifyListeners();
  }
}
