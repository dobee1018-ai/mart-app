import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../shared/mock_catalog.dart';
import '../shared/pantry_settings_sheet.dart';
import '../shared/pantry_store.dart';
import 'recipe_detail_page.dart';

class RecipePage extends StatelessWidget {
  const RecipePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: PantryStore.instance,
      builder: (context, child) {
        final store = PantryStore.instance;
        final recommendations = _rankRecipeRecommendations(store);
        final matchedRecipeCount = recommendations
            .where((entry) => entry.matchCount > 0)
            .length;

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              '오늘의 동네마트 특가와 냉장고 재료로 만드는 추천 레시피',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 16),
            _PersonalRecipeCard(
              selectedCount: store.selected.length,
              matchedRecipeCount: matchedRecipeCount,
            ),
            const SizedBox(height: 14),
            _BudgetCard(matchCount: store.selected.length),
            const SizedBox(height: 22),
            const _SectionTitle(
              icon: Icons.local_fire_department,
              text: '특가 상품 활용 레시피',
            ),
            const SizedBox(height: 12),
            _RecipeCarousel(recommendations: recommendations.take(10).toList()),
            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(
                  child: _SectionTitle(
                    icon: Icons.ac_unit,
                    text: '우리집 냉장고 비우기',
                  ),
                ),
                TextButton(
                  onPressed: () => showPantrySettingsSheet(context),
                  child: const Text('재료 설정'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _PantryChips(store: store),
            const SizedBox(height: 18),
            if (recommendations.isEmpty)
              const _NoRecipeCard()
            else
              ...recommendations
                  .take(8)
                  .map((entry) => _FridgeRecipeTile(entry: entry)),
          ],
        );
      },
    );
  }
}

class _PersonalRecipeCard extends StatelessWidget {
  const _PersonalRecipeCard({
    required this.selectedCount,
    required this.matchedRecipeCount,
  });

  final int selectedCount;
  final int matchedRecipeCount;

  @override
  Widget build(BuildContext context) {
    final hasIngredients = selectedCount > 0;
    return Card(
      elevation: 1,
      shadowColor: const Color(0x10000000),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFDDEFE5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: AppColors.softGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: AppColors.primaryGreen,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '내 재료 맞춤 추천',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        '없는 재료는 대체 재료로 조정해드릴게요',
                        style: TextStyle(
                          color: AppColors.textGray,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _StatusChip(
                  icon: Icons.kitchen_outlined,
                  text: hasIngredients ? '보유 재료 $selectedCount개' : '재료 설정 필요',
                  color: AppColors.primaryGreen,
                ),
                _StatusChip(
                  icon: Icons.restaurant_menu,
                  text: '추천 가능 $matchedRecipeCount개',
                  color: AppColors.accentOrange,
                ),
                const _StatusChip(
                  icon: Icons.straighten,
                  text: '계량 기준 변경',
                  color: AppColors.textGray,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => showPantrySettingsSheet(context),
                    icon: const Icon(Icons.tune, size: 18),
                    label: const Text('재료 설정'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => showPantrySettingsSheet(context),
                    icon: const Icon(Icons.search, size: 18),
                    label: const Text('맞춤 추천'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeCarousel extends StatefulWidget {
  const _RecipeCarousel({required this.recommendations});

  final List<_RecipeRecommendation> recommendations;

  @override
  State<_RecipeCarousel> createState() => _RecipeCarouselState();
}

class _RecipeCarouselState extends State<_RecipeCarousel> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: ScrollConfiguration(
        behavior: const _HorizontalDragScrollBehavior(),
        child: ListView.separated(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          itemCount: widget.recommendations.length,
          separatorBuilder: (context, index) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            return _RecipeCard(entry: widget.recommendations[index]);
          },
        ),
      ),
    );
  }
}

class _HorizontalDragScrollBehavior extends MaterialScrollBehavior {
  const _HorizontalDragScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({required this.matchCount});

  final int matchCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [AppColors.freshGreen, AppColors.primaryGreen],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '오늘의 예산 추천',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '1만원 이하 저녁 메뉴 3개',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '원주시 특가 재료와 보유 재료 $matchCount개를 함께 반영했어요.',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({required this.entry});

  final _RecipeRecommendation entry;

  @override
  Widget build(BuildContext context) {
    final recipe = entry.recipe;
    return SizedBox(
      width: 190,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: () => _openRecipeDetail(context, recipe),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 115,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      recipe.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const _ImageFallback(),
                    ),
                    Positioned(
                      left: 8,
                      bottom: 8,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.softGreen,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          child: Text(
                            entry.badgeText,
                            style: const TextStyle(
                              color: AppColors.primaryGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      recipe.reason,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${recipe.time} · ${recipe.difficulty} · ${_won(recipe.budget)}',
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      entry.summaryText,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PantryChips extends StatelessWidget {
  const _PantryChips({required this.store});

  final PantryStore store;

  @override
  Widget build(BuildContext context) {
    final selected = store.selected.toList()..sort();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: selected
          .map(
            (ingredient) => FilterChip(
              label: Text(ingredient),
              selected: true,
              onSelected: (_) => store.toggle(ingredient),
              avatar: const Icon(Icons.check, size: 16),
              showCheckmark: false,
              selectedColor: AppColors.primaryGreen,
              backgroundColor: AppColors.surface,
              side: const BorderSide(color: AppColors.primaryGreen, width: 1.2),
              labelStyle: const TextStyle(
                color: AppColors.surface,
                fontWeight: FontWeight.w900,
              ),
              iconTheme: const IconThemeData(color: AppColors.surface),
              elevation: 1.5,
              pressElevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
          )
          .toList(),
    );
  }
}

class _FridgeRecipeTile extends StatelessWidget {
  const _FridgeRecipeTile({required this.entry});

  final _RecipeRecommendation entry;

  @override
  Widget build(BuildContext context) {
    final recipe = entry.recipe;
    final tone = entry.ingredientTone;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.rice_bowl_outlined)),
        title: Text(recipe.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry.summaryText),
            if (entry.missingIngredients.isNotEmpty)
              Text(
                '부족: ${entry.missingIngredients.take(3).join(', ')}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.textGray, fontSize: 12),
              ),
          ],
        ),
        trailing: _IngredientStatusBadge(tone: tone),
        onTap: () => _openRecipeDetail(context, recipe),
      ),
    );
  }
}

class _IngredientStatusBadge extends StatelessWidget {
  const _IngredientStatusBadge({required this.tone});

  final _IngredientMatchTone tone;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tone.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tone.border, width: 1.15),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(tone.icon, size: 14, color: tone.foreground),
            const SizedBox(width: 4),
            Text(
              tone.label,
              style: TextStyle(
                color: tone.foreground,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoRecipeCard extends StatelessWidget {
  const _NoRecipeCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: const Padding(
        padding: EdgeInsets.all(18),
        child: Text(
          '재료를 추가하면 바로 만들 수 있는 메뉴부터 추천해드릴게요.',
          style: TextStyle(
            color: AppColors.textGray,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _RecipeRecommendation {
  const _RecipeRecommendation({
    required this.recipe,
    required this.matchCount,
    required this.missingIngredients,
    required this.discountMatchCount,
    required this.score,
  });

  final RecipeSuggestion recipe;
  final int matchCount;
  final List<String> missingIngredients;
  final int discountMatchCount;
  final int score;

  bool get isReady => missingIngredients.isEmpty;

  _IngredientMatchTone get ingredientTone {
    final total = recipe.ingredients.length;
    final missingCount = missingIngredients.length;
    final matchRatio = total == 0 ? 0 : matchCount / total;

    if (isReady || matchRatio >= 0.8) {
      return const _IngredientMatchTone(
        label: '바로 가능',
        icon: Icons.check_circle,
        background: AppColors.softGreen,
        border: Color(0xFFBFE8D2),
        foreground: AppColors.primaryGreen,
      );
    }

    if (matchCount >= 2 || matchRatio >= 0.4) {
      return _IngredientMatchTone(
        label: '$missingCount개 필요',
        icon: Icons.add_circle,
        background: AppColors.softOrange,
        border: const Color(0xFFFFD99B),
        foreground: AppColors.accentOrange,
      );
    }

    return const _IngredientMatchTone(
      label: '재료 부족',
      icon: Icons.error_outline,
      background: Color(0xFFFFEFEA),
      border: Color(0xFFFFC8B8),
      foreground: Color(0xFFE0522D),
    );
  }

  String get badgeText {
    if (isReady) return '바로 가능';
    if (missingIngredients.length == 1) return '1개만 추가';
    if (discountMatchCount > 0) return '특가 활용';
    return '$matchCount/${recipe.ingredients.length} 매칭';
  }

  String get summaryText {
    final total = recipe.ingredients.length;
    final discountText = discountMatchCount > 0
        ? ' · 특가 재료 $discountMatchCount개'
        : '';
    return '보유 재료 $matchCount/$total개$discountText';
  }
}

class _IngredientMatchTone {
  const _IngredientMatchTone({
    required this.label,
    required this.icon,
    required this.background,
    required this.border,
    required this.foreground,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color border;
  final Color foreground;
}

List<_RecipeRecommendation> _rankRecipeRecommendations(PantryStore store) {
  final selected = store.selected;
  final dealIds = dealItems.map((deal) => deal.id).toSet();
  final recommendations = recipeSuggestions.map((recipe) {
    final matchCount = store.matchCount(recipe.ingredients);
    final missing = recipe.ingredients
        .where((ingredient) => !selected.contains(ingredient))
        .toList();
    final discountMatchCount = recipe.relatedDealIds
        .where((dealId) => dealIds.contains(dealId))
        .length;
    final readyBonus = missing.isEmpty ? 12 : 0;
    final almostReadyBonus = missing.length == 1 ? 6 : 0;
    final budgetBonus = recipe.budget <= 7000 ? 3 : 0;
    final selectedPenalty = selected.isEmpty ? 0 : missing.length * 2;
    final score =
        (matchCount * 8) +
        (discountMatchCount * 3) +
        readyBonus +
        almostReadyBonus +
        budgetBonus -
        selectedPenalty;

    return _RecipeRecommendation(
      recipe: recipe,
      matchCount: matchCount,
      missingIngredients: missing,
      discountMatchCount: discountMatchCount,
      score: score,
    );
  }).toList();

  recommendations.sort((a, b) {
    final scoreCompare = b.score.compareTo(a.score);
    if (scoreCompare != 0) return scoreCompare;
    final matchCompare = b.matchCount.compareTo(a.matchCount);
    if (matchCompare != 0) return matchCompare;
    final missingCompare = a.missingIngredients.length.compareTo(
      b.missingIngredients.length,
    );
    if (missingCompare != 0) return missingCompare;
    return a.recipe.budget.compareTo(b.recipe.budget);
  });
  return recommendations;
}

void _openRecipeDetail(BuildContext context, RecipeSuggestion recipe) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) => RecipeDetailPage(recipe: recipe),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.softGreen),
      child: const Center(child: Icon(Icons.restaurant_menu, size: 38)),
    );
  }
}

String _won(int value) =>
    '₩${value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',')}';
