import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../shared/mock_catalog.dart';
import 'mart_detail_page.dart';

class MartsPage extends StatelessWidget {
  const MartsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _MartSummaryCard(),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            hintText: '마트 이름이나 상품 검색',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 18),
        ...flyerItems.map(
          (item) => _MartCard(
            item: item,
            dealCount: dealItems
                .where((deal) => deal.martName == item.martName)
                .length,
          ),
        ),
      ],
    );
  }
}

class _MartSummaryCard extends StatelessWidget {
  const _MartSummaryCard();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.frame),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: AppColors.softGreen,
              foregroundColor: AppColors.primaryGreen,
              child: Icon(Icons.storefront),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '원주 동네마트',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '등록 마트 ${flyerItems.length}곳 · 진행중인 특가 ${dealItems.length}개',
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
      ),
    );
  }
}

class _MartCard extends StatelessWidget {
  const _MartCard({required this.item, required this.dealCount});

  final FlyerItem item;
  final int dealCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: () => _openDetail(context, item),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      item.imageUrl,
                      width: 82,
                      height: 82,
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
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                item.martName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textDark,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _DealCountBadge(count: dealCount),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textGray,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _MetaLine(
                          icon: Icons.place_outlined,
                          text: item.address,
                        ),
                        const SizedBox(height: 4),
                        _MetaLine(
                          icon: Icons.schedule,
                          text: _displayInfo(
                            item.businessHours,
                            fallback: '영업시간 업데이트 예정',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _displayInfo(item.phoneNumber, fallback: '전화번호 업데이트 예정'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textGray,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _openDetail(context, item),
                    icon: const Icon(Icons.local_offer_outlined, size: 17),
                    label: const Text('특가 보기'),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DealCountBadge extends StatelessWidget {
  const _DealCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final hasDeals = count > 0;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: hasDeals ? AppColors.softOrange : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          hasDeals ? '특가 $count개' : '특가 준비중',
          style: TextStyle(
            color: hasDeals ? AppColors.accentOrange : AppColors.textGray,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textGray),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textGray,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
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

void _openDetail(BuildContext context, FlyerItem item) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (context) => MartDetailPage(flyer: item)),
  );
}

String _displayInfo(String value, {required String fallback}) {
  if (value.contains('정보 없음') || value.contains('확인 필요')) {
    return fallback;
  }
  return value;
}
