import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../product/product_detail_page.dart';
import '../shared/app_snack_bar.dart';
import '../shared/mock_catalog.dart';
import '../shared/pantry_settings_sheet.dart';
import '../shared/pantry_store.dart';

class RecipeDetailPage extends StatelessWidget {
  const RecipeDetailPage({super.key, required this.recipe});

  final RecipeSuggestion recipe;

  @override
  Widget build(BuildContext context) {
    final relatedDeals = dealItems
        .where((item) => recipe.relatedDealIds.contains(item.id))
        .toList();

    return ColoredBox(
      color: AppColors.frame,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                tooltip: '뒤로',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.chevron_left),
              ),
              title: const Text('레시피 상세'),
              actions: [
                IconButton(
                  tooltip: '재료 설정',
                  onPressed: () => showPantrySettingsSheet(context),
                  icon: const Icon(Icons.tune),
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                _RecipeHero(recipe: recipe),
                _RecipeSummary(recipe: recipe),
                _RecipeAdjustSection(recipe: recipe),
                const _SectionDivider(),
                _IngredientSection(recipe: recipe),
                const _SectionDivider(),
                _StepSection(recipe: recipe),
                const _SectionDivider(),
                _RelatedDealsSection(deals: relatedDeals),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecipeAdjustSection extends StatefulWidget {
  const _RecipeAdjustSection({required this.recipe});

  final RecipeSuggestion recipe;

  @override
  State<_RecipeAdjustSection> createState() => _RecipeAdjustSectionState();
}

class _RecipeAdjustSectionState extends State<_RecipeAdjustSection> {
  String _measureMode = 'spoon';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: PantryStore.instance,
      builder: (context, child) {
        final store = PantryStore.instance;
        final missing = store.missingIngredients(widget.recipe.ingredients);
        final substitutes = missing
            .take(3)
            .map(
              (ingredient) => _SubstituteSuggestion(
                ingredient: ingredient,
                substitute: _substituteFor(ingredient),
              ),
            )
            .toList();

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE7EFEA)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        '내 재료에 맞게 조정',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => showPantrySettingsSheet(context),
                      icon: const Icon(Icons.tune, size: 17),
                      label: const Text('재료'),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  '부족한 재료는 대체안을 보고, 원하는 계량 기준으로 확인하세요.',
                  style: TextStyle(
                    color: AppColors.textGray,
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MeasureChoice(
                      selected: _measureMode == 'spoon',
                      label: '밥숟가락',
                      onTap: () => setState(() => _measureMode = 'spoon'),
                    ),
                    _MeasureChoice(
                      selected: _measureMode == 'measure',
                      label: '계량스푼',
                      onTap: () => setState(() => _measureMode = 'measure'),
                    ),
                    _MeasureChoice(
                      selected: _measureMode == 'gram',
                      label: 'g/ml',
                      onTap: () => setState(() => _measureMode = 'gram'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _measureGuide(_measureMode),
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                if (missing.isEmpty)
                  const _ReadyToCookNotice()
                else ...[
                  const Text(
                    '대체 재료 제안',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...substitutes.map((item) => _SubstituteRow(item: item)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MeasureChoice extends StatelessWidget {
  const _MeasureChoice({
    required this.selected,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      selectedColor: AppColors.softGreen,
      labelStyle: TextStyle(
        color: selected ? AppColors.primaryGreen : AppColors.textGray,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _ReadyToCookNotice extends StatelessWidget {
  const _ReadyToCookNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.softGreen,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 19),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '보유 재료로 바로 조리 가능한 구성입니다.',
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubstituteRow extends StatelessWidget {
  const _SubstituteRow({required this.item});

  final _SubstituteSuggestion item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              item.ingredient,
              style: const TextStyle(
                color: AppColors.textGray,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 7),
            child: Icon(
              Icons.arrow_forward,
              size: 15,
              color: AppColors.textGray,
            ),
          ),
          Expanded(
            child: Text(
              item.substitute,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubstituteSuggestion {
  const _SubstituteSuggestion({
    required this.ingredient,
    required this.substitute,
  });

  final String ingredient;
  final String substitute;
}

String _measureGuide(String mode) {
  return switch (mode) {
    'measure' => '계량스푼 기준: 1큰술 15ml, 1작은술 5ml로 안내합니다.',
    'gram' => 'g/ml 기준: 액체는 ml, 고형 재료는 g 단위로 바꿔 보여줄 수 있습니다.',
    _ => '밥숟가락 기준: 간장/기름은 평평하게 1숟가락, 가루는 살짝 깎아서 잡아요.',
  };
}

String _substituteFor(String ingredient) {
  const substitutes = {
    '양파': '대파 흰 부분 또는 양배추',
    '대파': '쪽파 또는 양파 조금',
    '계란': '두부 으깬 것 또는 닭가슴살',
    '밥': '즉석밥 또는 냉동밥',
    '감자': '고구마 또는 단호박',
    '당근': '파프리카 또는 애호박',
    '카레가루': '짜장가루 또는 고형카레',
    '소금': '간장 소량',
    '설탕': '올리고당 또는 매실청',
    '식용유': '올리브유 또는 들기름',
    '간장': '소금+물 소량',
    '고춧가루': '고추장 소량',
    '참기름': '들기름 또는 깨',
  };
  return substitutes[ingredient] ?? '비슷한 식감의 채소나 오늘 할인 재료';
}

class _RecipeHero extends StatelessWidget {
  const _RecipeHero({required this.recipe});

  final RecipeSuggestion recipe;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            recipe.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const _ImageFallback(),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xCC000000)],
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Badge(text: recipe.tag),
                const SizedBox(height: 10),
                Text(
                  recipe.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${recipe.time} · ${recipe.difficulty} · 예상 ${_won(recipe.budget)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeSummary extends StatelessWidget {
  const _RecipeSummary({required this.recipe});

  final RecipeSuggestion recipe;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: PantryStore.instance,
      builder: (context, child) {
        final store = PantryStore.instance;
        final match = store.matchCount(recipe.ingredients);
        final total = recipe.ingredients.length;
        final missing = store.missingIngredients(recipe.ingredients);
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recipe.reason,
                style: const TextStyle(color: Color(0xFF4B5563), height: 1.5),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.softGreen,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.kitchen_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '보유 재료 $match/$total개 매칭'
                        '${missing.isEmpty ? ' · 바로 조리 가능' : ' · 부족: ${missing.take(3).join(', ')}'}',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _IngredientSection extends StatelessWidget {
  const _IngredientSection({required this.recipe});

  final RecipeSuggestion recipe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: AnimatedBuilder(
        animation: PantryStore.instance,
        builder: (context, child) {
          final store = PantryStore.instance;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(child: _SectionTitle('준비 재료')),
                  TextButton(
                    onPressed: () => showPantrySettingsSheet(context),
                    child: const Text('재료 설정'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: recipe.ingredients.map((ingredient) {
                  final owned = store.contains(ingredient);
                  return ActionChip(
                    avatar: Icon(
                      owned ? Icons.check_circle : Icons.add,
                      size: 18,
                      color: owned
                          ? const Color(0xFF168A52)
                          : AppColors.accentOrange,
                    ),
                    label: Text(ingredient),
                    tooltip: owned ? '보유 재료' : '우리집 재료에 추가',
                    onPressed: () {
                      if (owned) {
                        showTimedSnackBar(
                          context,
                          message: '$ingredient은 이미 우리집 재료에 있습니다.',
                        );
                        return;
                      }

                      store.add(ingredient);
                      showTimedSnackBar(
                        context,
                        message: '$ingredient을 우리집 재료에 추가했습니다.',
                      );
                    },
                    backgroundColor: owned
                        ? AppColors.softGreen
                        : AppColors.softOrange,
                    disabledColor: AppColors.softGreen,
                    side: BorderSide(
                      color: owned
                          ? const Color(0xFF2F9E65)
                          : const Color(0xFFFFD99B),
                      width: owned ? 1.35 : 1.1,
                    ),
                    labelStyle: TextStyle(
                      color: owned
                          ? const Color(0xFF168A52)
                          : AppColors.accentOrange,
                      fontWeight: FontWeight.w900,
                    ),
                    iconTheme: IconThemeData(
                      color: owned
                          ? AppColors.primaryGreen
                          : AppColors.accentOrange,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StepSection extends StatelessWidget {
  const _StepSection({required this.recipe});

  final RecipeSuggestion recipe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('조리 순서'),
          const SizedBox(height: 14),
          ...recipe.steps.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(radius: 15, child: Text('${entry.key + 1}')),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: const TextStyle(height: 1.45),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _RelatedDealsSection extends StatelessWidget {
  const _RelatedDealsSection({required this.deals});

  final List<DealItem> deals;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('이 레시피에 맞는 특가 제품'),
          const SizedBox(height: 12),
          if (deals.isEmpty)
            const Text('연결된 특가 상품이 없습니다.')
          else
            ...deals.map((deal) => _DealCard(deal: deal)),
        ],
      ),
    );
  }
}

class _DealCard extends StatelessWidget {
  const _DealCard({required this.deal});

  final DealItem deal;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => ProductDetailPage(item: deal),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  deal.imageUrl,
                  width: 78,
                  height: 78,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const _ImageFallback(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deal.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      deal.martName,
                      style: const TextStyle(color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Text(
                          '${deal.discountRate}%',
                          style: const TextStyle(
                            color: AppColors.accentOrange,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _won(deal.price),
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 8,
      child: DecoratedBox(
        decoration: BoxDecoration(color: AppColors.surfaceMuted),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.softGreen,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.primaryGreen,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.softGreen),
      child: const Center(child: Icon(Icons.restaurant_menu, size: 44)),
    );
  }
}

String _won(int value) =>
    '₩${value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',')}';
