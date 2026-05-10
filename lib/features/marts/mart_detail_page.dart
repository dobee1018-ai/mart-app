import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../my/my_page.dart';
import '../product/product_detail_page.dart';
import '../shared/catalog_image.dart';
import '../shared/external_actions.dart';
import '../shared/mock_catalog.dart';

class MartDetailPage extends StatelessWidget {
  const MartDetailPage({super.key, required this.flyer});

  final FlyerItem flyer;

  @override
  Widget build(BuildContext context) {
    final deals = dealItems
        .where((item) => item.martName == flyer.martName)
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
              title: const Text('동네마트'),
              actions: [
                IconButton(
                  tooltip: '즐겨찾기',
                  onPressed: () {},
                  icon: const Icon(Icons.star_border),
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                _MartSummary(flyer: flyer, dealCount: deals.length),
                if (flyer.flyerImageUrls.isNotEmpty) ...[
                  const _SectionDivider(),
                  _FlyerImageSection(flyer: flyer),
                ],
                const _SectionDivider(),
                _DealSection(deals: deals),
                const _SectionDivider(),
                _MartReviewSection(flyer: flyer),
                const _SectionDivider(),
                _SimpleInfoSection(flyer: flyer),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MartSummary extends StatelessWidget {
  const _MartSummary({required this.flyer, required this.dealCount});

  final FlyerItem flyer;
  final int dealCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.frame),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CatalogImage(
                  source: flyer.imageUrl,
                  width: 58,
                  height: 58,
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
                      flyer.martName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${_cleanInfo(flyer.businessHours)} · 특가 $dealCount개',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textGray,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => _showMartInfoSheet(context, flyer),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: const Text('더보기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlyerImageSection extends StatelessWidget {
  const _FlyerImageSection({required this.flyer});

  final FlyerItem flyer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: _SectionTitle('전단지 전체 보기')),
              Text(
                '${flyer.flyerImageUrls.length}장',
                style: const TextStyle(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...flyer.flyerImageUrls.indexed.map((entry) {
            final page = entry.$1 + 1;
            final imageUrl = entry.$2;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => _openFlyerPreview(context, imageUrl, page),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.frame),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AspectRatio(
                          aspectRatio: 1.45,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: CatalogImage(
                              source: imageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const _ImageFallback(),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          child: Row(
                            children: [
                              Text(
                                '전단 $page면',
                                style: const TextStyle(
                                  color: AppColors.textDark,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.zoom_out_map,
                                color: AppColors.primaryGreen,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _DealSection extends StatefulWidget {
  const _DealSection({required this.deals});

  final List<DealItem> deals;

  @override
  State<_DealSection> createState() => _DealSectionState();
}

class _DealSectionState extends State<_DealSection> {
  final _searchController = TextEditingController();
  String _query = '';
  String _selectedCategory = _allCategoryKey;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = _dealCategories(widget.deals);
    final visibleDeals = widget.deals.where(_matchesFilter).toList();
    final hasFilter =
        _query.trim().isNotEmpty || _selectedCategory != _allCategoryKey;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: _SectionTitle('진행중인 특가 상품')),
              Text(
                '${visibleDeals.length}/${widget.deals.length}개',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _DealSearchField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            onClear: () {
              _searchController.clear();
              setState(() => _query = '');
            },
          ),
          const SizedBox(height: 10),
          _DealCategoryChips(
            categories: categories,
            selectedCategory: _selectedCategory,
            deals: widget.deals,
            onSelected: (category) {
              setState(() => _selectedCategory = category);
            },
          ),
          const SizedBox(height: 12),
          if (widget.deals.isEmpty)
            const _EmptyDealCard()
          else if (visibleDeals.isEmpty)
            _EmptyDealCard(
              text: hasFilter ? '조건에 맞는 특가 상품이 없습니다.' : '아직 진행중인 특가 상품이 없습니다.',
              icon: Icons.search_off,
            )
          else
            ...visibleDeals.map((deal) => _DealTile(deal: deal)),
        ],
      ),
    );
  }

  bool _matchesFilter(DealItem deal) {
    final matchesCategory =
        _selectedCategory == _allCategoryKey ||
        deal.category == _selectedCategory;
    if (!matchesCategory) {
      return false;
    }

    final normalizedQuery = _normalize(_query);
    if (normalizedQuery.isEmpty) {
      return true;
    }

    final comparisonText = deal.comparisons
        .map((comparison) => '${comparison.unit} ${comparison.period}')
        .join(' ');
    final searchable = _normalize(
      '${deal.title} ${deal.badge} ${deal.description} ${deal.price} $comparisonText',
    );
    return searchable.contains(normalizedQuery);
  }
}

class _DealSearchField extends StatelessWidget {
  const _DealSearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        return TextField(
          controller: controller,
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: '상품명 검색',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    tooltip: '검색어 지우기',
                    onPressed: onClear,
                    icon: const Icon(Icons.close),
                  ),
            filled: true,
            fillColor: AppColors.surface,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.frame),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.frame),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 1.4,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DealCategoryChips extends StatelessWidget {
  const _DealCategoryChips({
    required this.categories,
    required this.selectedCategory,
    required this.deals,
    required this.onSelected,
  });

  final List<String> categories;
  final String selectedCategory;
  final List<DealItem> deals;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final isSelected = category == selectedCategory;
          final count = category == _allCategoryKey
              ? deals.length
              : deals.where((deal) => deal.category == category).length;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text('${_categoryLabel(category)} $count'),
              selected: isSelected,
              onSelected: (_) => onSelected(category),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textDark,
                fontWeight: FontWeight.w900,
              ),
              selectedColor: AppColors.primaryGreen,
              backgroundColor: AppColors.surface,
              side: BorderSide(
                color: isSelected ? AppColors.primaryGreen : AppColors.frame,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          );
        }).toList(),
      ),
    );
  }
}

List<String> _dealCategories(List<DealItem> deals) {
  final found = deals.map((deal) => deal.category).toSet();
  final ordered = [
    _allCategoryKey,
    ..._categoryOrder.where(found.contains),
    ...found.where((category) => !_categoryOrder.contains(category)).toList()
      ..sort(),
  ];
  return ordered;
}

String _categoryLabel(String category) {
  return switch (category) {
    _allCategoryKey => '전체',
    'meat' => '정육',
    'veg' => '과일·채소',
    'seafood' => '수산',
    'dairy' => '유제품',
    'rice' => '쌀·잡곡',
    'processed' => '가공식품',
    'seasoning' => '양념',
    'living' => '생활',
    _ => '기타',
  };
}

String _normalize(String value) {
  return value.toLowerCase().replaceAll(RegExp(r'\s+'), '').replaceAll(',', '');
}

const _allCategoryKey = 'all';
const _categoryOrder = [
  'meat',
  'veg',
  'seafood',
  'dairy',
  'rice',
  'processed',
  'seasoning',
  'living',
];

class _DealTile extends StatelessWidget {
  const _DealTile({required this.deal});

  final DealItem deal;

  @override
  Widget build(BuildContext context) {
    final comparison = deal.comparisons.firstOrNull;

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
                child: CatalogImage(
                  source: deal.imageUrl,
                  width: 76,
                  height: 76,
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
                      '${_categoryLabel(deal.category)} · ${deal.badge}',
                      style: const TextStyle(color: AppColors.textGray),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          deal.discountRate > 0
                              ? '${deal.discountRate}%'
                              : '전단가',
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
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    if (comparison != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        '${comparison.unit} · ${comparison.period}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textGray,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
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

class _SimpleInfoSection extends StatelessWidget {
  const _SimpleInfoSection({required this.flyer});

  final FlyerItem flyer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: _SectionTitle('마트 안내')),
              TextButton(
                onPressed: () => _showMartInfoSheet(context, flyer),
                child: const Text('자세히'),
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
              child: Column(
                children: [
                  _CompactInfoLine(
                    icon: Icons.place_outlined,
                    text: flyer.address,
                  ),
                  const SizedBox(height: 8),
                  _CompactInfoLine(
                    icon: Icons.schedule,
                    text: _cleanInfo(flyer.businessHours),
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

class _MartReviewSection extends StatelessWidget {
  const _MartReviewSection({required this.flyer});

  final FlyerItem flyer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: _SectionTitle('마트 리뷰')),
              TextButton.icon(
                onPressed: () => _openMartReview(context, flyer.martName),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: AppColors.accentOrange,
                        size: 22,
                      ),
                      SizedBox(width: 6),
                      Text(
                        '4.6',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(width: 6),
                      Text(
                        '최근 리뷰 12개',
                        style: TextStyle(
                          color: AppColors.textGray,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '신선식품 회전이 빠르고 주차가 편했다는 후기가 많아요.',
                    style: TextStyle(
                      color: Color(0xFF4B5563),
                      height: 1.45,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _openMartReview(context, flyer.martName),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('이 마트 리뷰 작성하기'),
                    ),
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

class _MartInfoSheet extends StatelessWidget {
  const _MartInfoSheet({required this.flyer, required this.scrollController});

  final FlyerItem flyer;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
        children: [
          const _SheetHandle(),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: CatalogImage(
                  source: flyer.imageUrl,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const _ImageFallback(),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      flyer.martName,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        height: 1.22,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      flyer.title,
                      style: const TextStyle(
                        color: AppColors.textGray,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            flyer.description,
            style: const TextStyle(
              color: Color(0xFF4B5563),
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          _InfoRow(
            icon: Icons.place_outlined,
            label: '주소',
            value: flyer.address,
          ),
          _InfoRow(
            icon: Icons.schedule,
            label: '영업시간',
            value: _cleanInfo(flyer.businessHours),
          ),
          _InfoRow(
            icon: Icons.calendar_month_outlined,
            label: '휴무일',
            value: _cleanInfo(flyer.closedDays),
          ),
          _InfoRow(
            icon: Icons.phone_outlined,
            label: '전화번호',
            value: _cleanInfo(flyer.phoneNumber),
            onTap: () => launchPhoneDialer(context, flyer.phoneNumber),
          ),
          _InfoRow(
            icon: Icons.local_parking,
            label: '주차',
            value: _cleanInfo(flyer.parkingInfo),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => showMapLauncherSheet(
                    context,
                    martName: flyer.martName,
                    address: flyer.address,
                  ),
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('길찾기'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      launchPhoneDialer(context, flyer.phoneNumber),
                  icon: const Icon(Icons.phone_outlined),
                  label: const Text('전화하기'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.star_outline),
                  label: const Text('저장'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyDealCard extends StatelessWidget {
  const _EmptyDealCard({
    this.text = '아직 진행중인 특가 상품이 없습니다.',
    this.icon = Icons.local_offer_outlined,
  });

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(child: Icon(icon)),
            const SizedBox(width: 12),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 21),
            const SizedBox(width: 10),
            SizedBox(
              width: 68,
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.textGray,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  color: onTap == null
                      ? AppColors.textDark
                      : AppColors.primaryGreen,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactInfoLine extends StatelessWidget {
  const _CompactInfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textGray,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 42,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.frame,
          borderRadius: BorderRadius.circular(999),
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

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(color: AppColors.softGreen),
      child: Center(child: Icon(Icons.storefront, size: 36)),
    );
  }
}

void _showMartInfoSheet(BuildContext context, FlyerItem flyer) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.58,
        minChildSize: 0.36,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: _MartInfoSheet(
                flyer: flyer,
                scrollController: scrollController,
              ),
            ),
          );
        },
      );
    },
  );
}

void _openFlyerPreview(BuildContext context, String imageUrl, int page) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) => ColoredBox(
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
                title: Text('전단 $page면'),
              ),
              body: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4,
                child: Center(
                  child: CatalogImage(
                    source: imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const _ImageFallback(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

void _openMartReview(BuildContext context, String martName) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) => ReviewDetailPage(initialTarget: martName),
    ),
  );
}

String _won(int value) =>
    '₩${value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',')}';

String _cleanInfo(String value) {
  if (value.contains('확인 필요') || value.contains('정보 없음')) {
    return '업데이트 예정';
  }
  return value;
}
