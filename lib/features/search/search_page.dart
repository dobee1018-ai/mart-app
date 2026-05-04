import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../my/my_page.dart';
import '../product/product_detail_page.dart';
import '../shared/app_snack_bar.dart';
import '../shared/mock_catalog.dart';
import '../shared/shopping_list_store.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, required this.onReportTap});

  final VoidCallback onReportTap;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _category = 'all';

  @override
  Widget build(BuildContext context) {
    final filtered = _category == 'all'
        ? dealItems
        : dealItems.where((item) => item.category == _category).toList();
    final heroItem = dealItems.firstWhere(
      (item) => item.id == 'egg',
      orElse: () => dealItems.first,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 96),
      children: [
        _FreshHeader(totalDeals: dealItems.length),
        const SizedBox(height: 14),
        const _SearchBox(),
        const SizedBox(height: 16),
        _HeroDeal(item: heroItem),
        const SizedBox(height: 18),
        _CategoryChips(
          selected: _category,
          onSelected: (value) => setState(() => _category = value),
        ),
        const SizedBox(height: 14),
        _SectionTitle(count: filtered.length),
        const SizedBox(height: 12),
        _ProductGrid(items: filtered),
      ],
    );
  }
}

class _FreshHeader extends StatelessWidget {
  const _FreshHeader({required this.totalDeals});

  final int totalDeals;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    '원주시',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                '동네마트 특가를 신선하게 모아봤어요',
                style: TextStyle(
                  color: AppColors.textGray,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.softOrange,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFFFE3B8)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.local_fire_department,
                color: AppColors.accentOrange,
                size: 17,
              ),
              const SizedBox(width: 4),
              Text(
                '$totalDeals개 특가',
                style: const TextStyle(
                  color: AppColors.accentOrange,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox();

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: '특가 상품이나 마트를 검색해보세요',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _HeroDeal extends StatelessWidget {
  const _HeroDeal({required this.item});

  final DealItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _openDetail(context, item),
      child: Container(
        height: 306,
        decoration: BoxDecoration(
          color: const Color(0xFFF0FAF4),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFCDEEDB)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x160F7A4B),
              blurRadius: 22,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Container(width: 126, color: AppColors.softOrange),
              ),
              Positioned(
                right: -22,
                bottom: -18,
                child: Container(
                  width: 206,
                  height: 206,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: 14,
                bottom: 20,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 152,
                      height: 152,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x17000000),
                            blurRadius: 16,
                            offset: Offset(0, 7),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.network(
                          item.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const _ImageFallback(),
                        ),
                      ),
                    ),
                    Positioned(
                      right: -2,
                      top: -12,
                      child: _DiscountBurst(rate: item.discountRate),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 16,
                child: Row(
                  children: [
                    _MiniInfoChip(
                      icon: Icons.verified_outlined,
                      text: '마트 특가 제보',
                    ),
                    const SizedBox(width: 7),
                    _MiniInfoChip(icon: Icons.schedule, text: '오늘 장보기 추천'),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 160, 52),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _HeroBadge(),
                    const SizedBox(height: 12),
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.martName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textGray,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _won(item.price),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '정상가 ${_won(item.originalPrice)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textGray,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(height: 10),
                    FilledButton.icon(
                      onPressed: () => _openDetail(context, item),
                      icon: const Icon(Icons.arrow_forward, size: 17),
                      label: const Text('특가 보기'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(118, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        visualDensity: VisualDensity.compact,
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

class _MiniInfoChip extends StatelessWidget {
  const _MiniInfoChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.86),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFE7F4EC)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.primaryGreen),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.primaryGreen,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscountBurst extends StatelessWidget {
  const _DiscountBurst({required this.rate});

  final int rate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: AppColors.accentOrange,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surface, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$rate%',
          style: const TextStyle(
            color: AppColors.surface,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            '오늘의 특가 상품',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Text(
          '$count개',
          style: const TextStyle(
            color: AppColors.primaryGreen,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.softOrange,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          '오늘의 대표 특가',
          style: TextStyle(
            color: AppColors.accentOrange,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _CategoryChips extends StatefulWidget {
  const _CategoryChips({required this.selected, required this.onSelected});

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  State<_CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<_CategoryChips> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const chips = [
      ('all', '전체보기'),
      ('meat', '정육/계란'),
      ('veg', '채소/과일'),
      ('dairy', '유제품'),
      ('rice', '쌀/잡곡'),
      ('processed', '공산품'),
      ('seasoning', '조미료'),
      ('living', '생활용품'),
    ];

    return SizedBox(
      height: 42,
      child: ScrollConfiguration(
        behavior: const _HorizontalDragScrollBehavior(),
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: Row(
            children: chips.map((chip) {
              final active = widget.selected == chip.$1;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(chip.$2),
                  selected: active,
                  onSelected: (_) => widget.onSelected(chip.$1),
                  backgroundColor: AppColors.surface,
                  selectedColor: AppColors.softGreen,
                  side: BorderSide(
                    color: active ? AppColors.softGreen : AppColors.frame,
                  ),
                  labelStyle: TextStyle(
                    color: active ? AppColors.primaryGreen : AppColors.textGray,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                  showCheckmark: false,
                ),
              );
            }).toList(),
          ),
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

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.items});

  final List<DealItem> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 12) / 2;
        final cardHeight = _productImageHeight(cardWidth) + 104;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: cardWidth / cardHeight,
          ),
          itemBuilder: (context, index) => _ProductGridCard(item: items[index]),
        );
      },
    );
  }
}

class _ProductGridCard extends StatelessWidget {
  const _ProductGridCard({required this.item});

  final DealItem item;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Card(
          elevation: 2,
          shadowColor: const Color(0x12000000),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFFEAF0ED)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _openDetail(context, item),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: _productImageHeight(constraints.maxWidth),
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const _ImageFallback(),
                      ),
                      Positioned(
                        left: 8,
                        top: 8,
                        child: _Badge(text: item.badge, compact: true),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentOrange,
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x22000000),
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            '${item.discountRate}%',
                            style: const TextStyle(
                              color: AppColors.surface,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          item.martName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textGray,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                _won(item.price),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textDark,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            SizedBox(
                              width: 30,
                              height: 30,
                              child: IconButton(
                                tooltip: '담기',
                                onPressed: () => _addDealToCart(context, item),
                                style: IconButton.styleFrom(
                                  backgroundColor: AppColors.softGreen,
                                  foregroundColor: AppColors.primaryGreen,
                                  padding: EdgeInsets.zero,
                                ),
                                icon: const Icon(Icons.add, size: 18),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

double _productImageHeight(double cardWidth) =>
    (cardWidth / 1.08).clamp(140.0, 170.0).toDouble();

void _openDetail(BuildContext context, DealItem item) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) => ProductDetailPage(item: item),
    ),
  );
}

void _addDealToCart(BuildContext context, DealItem item) {
  ShoppingListStore.instance.addDealToCart(item);
  showTimedSnackBar(
    context,
    message: '${item.title}을 장바구니에 담았습니다.',
    actionLabel: '보기',
    onAction: () => _openCartDetail(context),
  );
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

class _Badge extends StatelessWidget {
  const _Badge({required this.text, this.compact = false});

  final String text;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.softGreen,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 7 : 9,
          vertical: compact ? 3 : 5,
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.primaryGreen,
            fontSize: compact ? 11 : 12,
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
    return const DecoratedBox(
      decoration: BoxDecoration(color: AppColors.softGreen),
      child: Center(child: Icon(Icons.image_outlined, size: 38)),
    );
  }
}

String _won(int value) =>
    '₩${value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',')}';
