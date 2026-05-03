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
        final fridgeRecipes =
            recipeSuggestions
                .where((recipe) => store.matchCount(recipe.ingredients) > 0)
                .toList()
              ..sort(
                (a, b) => store
                    .matchCount(b.ingredients)
                    .compareTo(store.matchCount(a.ingredients)),
              );

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              '오늘의 동네마트 특가와 냉장고 재료로 만드는 추천 레시피',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 16),
            _BudgetCard(matchCount: store.selected.length),
            const SizedBox(height: 22),
            const _SectionTitle(
              icon: Icons.local_fire_department,
              text: '특가 상품 활용 레시피',
            ),
            const SizedBox(height: 12),
            const _RecipeCarousel(),
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
            ...fridgeRecipes.map((recipe) => _FridgeRecipeTile(recipe: recipe)),
          ],
        );
      },
    );
  }
}

class _RecipeCarousel extends StatefulWidget {
  const _RecipeCarousel();

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
          itemCount: recipeSuggestions.length,
          separatorBuilder: (context, index) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            return _RecipeCard(recipe: recipeSuggestions[index]);
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
  const _RecipeCard({required this.recipe});

  final RecipeSuggestion recipe;

  @override
  Widget build(BuildContext context) {
    final store = PantryStore.instance;
    final match = store.matchCount(recipe.ingredients);
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
                            recipe.tag,
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
                      '보유 재료 $match/${recipe.ingredients.length}개 매칭',
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
            ),
          )
          .toList(),
    );
  }
}

class _FridgeRecipeTile extends StatelessWidget {
  const _FridgeRecipeTile({required this.recipe});

  final RecipeSuggestion recipe;

  @override
  Widget build(BuildContext context) {
    final store = PantryStore.instance;
    final match = store.matchCount(recipe.ingredients);
    final owned = recipe.ingredients.where(store.contains).join(', ');
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.rice_bowl_outlined)),
        title: Text(recipe.title),
        subtitle: Text('보유 재료 매칭: $owned'),
        trailing: Text(
          '$match/${recipe.ingredients.length}',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
        onTap: () => _openRecipeDetail(context, recipe),
      ),
    );
  }
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
