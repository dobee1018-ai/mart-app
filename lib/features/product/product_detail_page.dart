import 'package:flutter/material.dart';

import '../../models/app_enums.dart';
import '../../theme/app_colors.dart';
import '../marts/mart_detail_page.dart';
import '../memo/memo_page.dart';
import '../my/my_page.dart';
import '../shared/app_snack_bar.dart';
import '../shared/external_actions.dart';
import '../shared/mock_catalog.dart';
import '../shared/shopping_list_store.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key, required this.item});

  final DealItem item;

  @override
  Widget build(BuildContext context) {
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
              title: const Text('상품 상세'),
              actions: [
                IconButton(
                  tooltip: '찜하기',
                  onPressed: () {},
                  icon: const Icon(Icons.favorite_border),
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.only(bottom: 110),
              children: [
                _ProductHero(item: item),
                _ProductSummary(item: item),
                const _SectionDivider(),
                _DescriptionSection(description: item.description),
                const _SectionDivider(),
                _ProductReviewSection(item: item),
                const _SectionDivider(),
                _PriceComparisonSection(item: item),
              ],
            ),
            bottomNavigationBar: _BottomActionBar(item: item),
          ),
        ),
      ),
    );
  }
}

class _ProductHero extends StatelessWidget {
  const _ProductHero({required this.item});

  final DealItem item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 270,
      width: double.infinity,
      child: Image.network(
        item.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const _ImageFallback(),
      ),
    );
  }
}

class _ProductSummary extends StatelessWidget {
  const _ProductSummary({required this.item});

  final DealItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _Badge(text: item.martName, icon: Icons.storefront),
              _Badge(text: item.badge),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              height: 1.18,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.discountRate}%',
                style: const TextStyle(
                  color: AppColors.accentOrange,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _won(item.price),
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  _won(item.originalPrice),
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    decoration: TextDecoration.lineThrough,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '마트별 특가 ${item.comparisons.length}개',
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DescriptionSection extends StatelessWidget {
  const _DescriptionSection({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('상품 설명'),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 15,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductReviewSection extends StatelessWidget {
  const _ProductReviewSection({required this.item});

  final DealItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: _SectionTitle('상품 리뷰')),
              TextButton.icon(
                onPressed: () => _openProductReview(context, item),
                icon: const Icon(Icons.rate_review_outlined, size: 18),
                label: const Text('작성'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.frame),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: AppColors.softOrange,
                    foregroundColor: AppColors.accentOrange,
                    child: Icon(Icons.inventory_2_outlined),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      '이 상품의 신선도와 가격 만족도를 남겨주세요. 상품 리뷰는 상품 상세에서만 작성됩니다.',
                      style: TextStyle(
                        color: Color(0xFF4B5563),
                        height: 1.42,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonal(
                    onPressed: () => _openProductReview(context, item),
                    child: const Text('쓰기'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceComparisonSection extends StatelessWidget {
  const _PriceComparisonSection({required this.item});

  final DealItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: _SectionTitle('마트별 특가 정보')),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.tune, size: 18),
                label: const Text('정렬'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...item.comparisons.map(
            (comparison) => _MartPriceCard(comparison: comparison),
          ),
        ],
      ),
    );
  }
}

class _MartPriceCard extends StatelessWidget {
  const _MartPriceCard({required this.comparison});

  final MartPriceComparison comparison;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: comparison.isCheapest ? primary : AppColors.frame,
          width: comparison.isCheapest ? 1.6 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        comparison.martName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (comparison.isCheapest)
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.softOrange,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            child: Text(
                              '대표 특가',
                              style: TextStyle(
                                color: AppColors.accentOrange,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  _won(comparison.price),
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              comparison.productName,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(icon: Icons.scale_outlined, text: comparison.unit),
                _InfoChip(
                  icon: Icons.place_outlined,
                  text: comparison.distance,
                ),
                _InfoChip(icon: Icons.event_outlined, text: comparison.period),
                _InfoChip(
                  icon: Icons.local_parking,
                  text: comparison.hasParking ? '주차 가능' : '온라인/배송',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _openComparisonMap(context, comparison.martName),
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('길찾기'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _addComparisonToCart(context, comparison),
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('담기'),
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

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: const Color(0xFF6B7280)),
            const SizedBox(width: 4),
            Text(
              text,
              style: const TextStyle(
                color: Color(0xFF4B5563),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({required this.item});

  final DealItem item;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.frame)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _addMemoFromDeal(context, item),
                icon: const Icon(Icons.edit_note),
                label: const Text('메모'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: () => _openMartDeals(context, item.martName),
                child: Text('${item.martName} 특가 보기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _addComparisonToCart(
  BuildContext context,
  MartPriceComparison comparison,
) {
  ShoppingListStore.instance.addComparisonToCart(comparison);
  showTimedSnackBar(
    context,
    message: '${comparison.productName}을 장바구니에 담았습니다.',
    actionLabel: '보기',
    onAction: () => _openCartDetail(context),
  );
}

void _addMemoFromDeal(BuildContext context, DealItem item) {
  ShoppingListStore.instance.addMemo(item.title);
  showTimedSnackBar(
    context,
    message: '${item.title}을 장보기 메모에 추가했습니다.',
    actionLabel: '보기',
    onAction: () => _openMemoPage(context),
  );
}

void _openMartDeals(BuildContext context, String martName) {
  final flyer = findFlyerByMartName(martName);
  if (flyer == null) {
    _showReadySnack(context, '$martName 정보는 준비 중입니다.');
    return;
  }
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (context) => MartDetailPage(flyer: flyer)),
  );
}

void _openProductReview(BuildContext context, DealItem item) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) => ReviewDetailPage(
        initialTarget: item.title,
        targetType: ReviewTargetType.product,
      ),
    ),
  );
}

void _openComparisonMap(BuildContext context, String martName) {
  final flyer = findFlyerByMartName(martName);
  showMapLauncherSheet(context, martName: martName, address: flyer?.address);
}

void _showReadySnack(BuildContext context, String message) {
  showTimedSnackBar(context, message: message);
}

void _openCartDetail(BuildContext context) {
  final store = ShoppingListStore.instance;
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) => CartDetailPage(
        cartGroups: store.cartGroups,
        onRemoveGroup: store.removeCartGroup,
        onRemoveLine: store.removeCartLine,
      ),
    ),
  );
}

void _openMemoPage(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (context) => const MemoPage()));
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
  const _Badge({required this.text, this.icon});

  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.softGreen,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: AppColors.primaryGreen),
              const SizedBox(width: 4),
            ],
            Text(
              text,
              style: const TextStyle(
                color: AppColors.primaryGreen,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
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
      child: const Center(child: Icon(Icons.image_outlined, size: 46)),
    );
  }
}

String _won(int value) =>
    '₩${value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',')}';
