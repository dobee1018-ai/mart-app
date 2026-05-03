import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../product/product_detail_page.dart';
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
                  return Chip(
                    avatar: Icon(
                      owned ? Icons.check_circle : Icons.add_circle_outline,
                      size: 18,
                    ),
                    label: Text(ingredient),
                    backgroundColor: owned
                        ? AppColors.softGreen
                        : AppColors.surfaceMuted,
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
