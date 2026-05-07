import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../theme/app_colors.dart';
import '../shared/catalog_image.dart';
import '../shared/external_actions.dart';
import '../shared/mock_catalog.dart';
import 'mart_detail_page.dart';

class MartsPage extends StatefulWidget {
  const MartsPage({super.key});

  @override
  State<MartsPage> createState() => _MartsPageState();
}

class _MartsPageState extends State<MartsPage> {
  String _query = '';
  String _filter = 'all';
  Position? _currentPosition;
  bool _locationBusy = false;
  String? _locationMessage;

  @override
  Widget build(BuildContext context) {
    final marts = flyerItems
        .map((item) {
          final distanceMeters = _currentPosition == null
              ? null
              : Geolocator.distanceBetween(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                  item.latitude,
                  item.longitude,
                );
          return _MartListEntry(
            item: item,
            dealCount: _dealCount(item),
            distanceMeters: distanceMeters,
          );
        })
        .where((entry) {
          final item = entry.item;
          final dealCount = _dealCount(item);
          final queryMatch =
              _query.isEmpty ||
              item.martName.contains(_query) ||
              item.address.contains(_query) ||
              item.title.contains(_query);
          final filterMatch = switch (_filter) {
            'deals' => dealCount > 0,
            'nearby' =>
              entry.distanceMeters == null || entry.distanceMeters! <= 5000,
            'open24' => item.businessHours.contains('24시간'),
            'needsCheck' =>
              item.businessHours.contains('확인 필요') ||
                  item.businessHours.contains('정보 없음') ||
                  item.parkingInfo.contains('확인 필요'),
            _ => true,
          };
          return queryMatch && filterMatch;
        })
        .toList();

    if (_currentPosition != null) {
      marts.sort(
        (a, b) => (a.distanceMeters ?? double.infinity).compareTo(
          b.distanceMeters ?? double.infinity,
        ),
      );
    }

    return ColoredBox(
      color: AppColors.background,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const _MartSummaryCard(),
          const SizedBox(height: 16),
          TextField(
            onChanged: (value) => setState(() => _query = value.trim()),
            decoration: InputDecoration(
              hintText: '마트 이름이나 상품 검색',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppColors.surface,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE7EFEA)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AppColors.primaryGreen,
                  width: 1.3,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _MartFilterChips(selected: _filter, onSelected: _selectFilter),
          const SizedBox(height: 10),
          _LocationSortCard(
            hasLocation: _currentPosition != null,
            isBusy: _locationBusy,
            message: _locationMessage,
            onTap: _useCurrentLocation,
          ),
          const SizedBox(height: 18),
          if (marts.isEmpty)
            const _EmptyMartCard()
          else
            ...marts.map(
              (entry) => _MartCard(
                item: entry.item,
                dealCount: entry.dealCount,
                distanceText: _formatDistance(entry.distanceMeters),
              ),
            ),
        ],
      ),
    );
  }

  int _dealCount(FlyerItem item) {
    return dealItems.where((deal) => deal.martName == item.martName).length;
  }

  Future<void> _selectFilter(String value) async {
    if (!mounted) return;
    setState(() => _filter = value);
    if (value == 'nearby' && _currentPosition == null) {
      await _useCurrentLocation();
    }
  }

  Future<void> _useCurrentLocation() async {
    if (_locationBusy || !mounted) return;
    setState(() {
      _locationBusy = true;
      _locationMessage = null;
    });
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!mounted) return;
      if (!serviceEnabled) {
        setState(() {
          _locationMessage = '기기 위치 서비스가 꺼져 있어요.';
        });
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (!mounted) return;

      if (permission == LocationPermission.denied) {
        setState(() {
          _locationMessage = '위치 권한을 허용하면 가까운 순으로 볼 수 있어요.';
        });
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationMessage = '브라우저/기기 설정에서 위치 권한을 허용해주세요.';
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      if (!mounted) return;
      setState(() {
        _currentPosition = position;
        _locationMessage = '현재 위치 기준 가까운 순으로 정렬 중입니다.';
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _locationMessage = '현재 위치를 가져오지 못했어요. 잠시 후 다시 시도해주세요.';
      });
    } finally {
      if (mounted) {
        setState(() => _locationBusy = false);
      }
    }
  }
}

class _MartListEntry {
  const _MartListEntry({
    required this.item,
    required this.dealCount,
    required this.distanceMeters,
  });

  final FlyerItem item;
  final int dealCount;
  final double? distanceMeters;
}

String? _formatDistance(double? meters) {
  if (meters == null) return null;
  if (meters < 1000) {
    return '${meters.round()}m';
  }
  return '${(meters / 1000).toStringAsFixed(1)}km';
}

class _MartSummaryCard extends StatelessWidget {
  const _MartSummaryCard();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDEFE5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F7A4B),
            blurRadius: 16,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
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
            const SizedBox(height: 13),
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _SummaryChip(icon: Icons.local_offer_outlined, text: '특가 진행중'),
                _SummaryChip(icon: Icons.schedule, text: '24시간 마트'),
                _SummaryChip(icon: Icons.place_outlined, text: '원주시 기준'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.softGreen,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primaryGreen, size: 14),
            const SizedBox(width: 4),
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

class _MartFilterChips extends StatelessWidget {
  const _MartFilterChips({required this.selected, required this.onSelected});

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    const filters = [
      ('all', '전체'),
      ('nearby', '가까운 순'),
      ('deals', '특가 있음'),
      ('open24', '24시간'),
      ('needsCheck', '확인 필요'),
    ];
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final active = selected == filter.$1;
          return ChoiceChip(
            label: Text(filter.$2),
            selected: active,
            onSelected: (_) => onSelected(filter.$1),
            showCheckmark: false,
            selectedColor: AppColors.softGreen,
            backgroundColor: AppColors.surface,
            side: BorderSide(
              color: active ? const Color(0xFFDDEFE5) : AppColors.frame,
            ),
            labelStyle: TextStyle(
              color: active ? AppColors.primaryGreen : AppColors.textGray,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          );
        },
      ),
    );
  }
}

class _LocationSortCard extends StatelessWidget {
  const _LocationSortCard({
    required this.hasLocation,
    required this.isBusy,
    required this.message,
    required this.onTap,
  });

  final bool hasLocation;
  final bool isBusy;
  final String? message;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: hasLocation ? AppColors.softGreen : AppColors.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: hasLocation ? const Color(0xFFDDEFE5) : AppColors.frame,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        child: Row(
          children: [
            Icon(
              hasLocation ? Icons.my_location : Icons.location_searching,
              color: AppColors.primaryGreen,
              size: 20,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                message ??
                    (hasLocation
                        ? '현재 위치 기준으로 가까운 마트부터 보여드려요.'
                        : '현재 위치를 켜면 가까운 마트부터 볼 수 있어요.'),
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton(
              onPressed: isBusy ? null : onTap,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: AppColors.primaryGreen,
              ),
              child: Text(
                isBusy
                    ? '확인 중'
                    : hasLocation
                    ? '새로고침'
                    : '위치 사용',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyMartCard extends StatelessWidget {
  const _EmptyMartCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: const Padding(
        padding: EdgeInsets.all(22),
        child: Center(
          child: Text(
            '조건에 맞는 마트가 없습니다.',
            style: TextStyle(
              color: AppColors.textGray,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _MartCard extends StatelessWidget {
  const _MartCard({
    required this.item,
    required this.dealCount,
    required this.distanceText,
  });

  final FlyerItem item;
  final int dealCount;
  final String? distanceText;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      surfaceTintColor: AppColors.surface,
      elevation: 1.5,
      shadowColor: const Color(0x100F7A4B),
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE2F0E8)),
      ),
      child: InkWell(
        onTap: () => _openDetail(context, item),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: AppColors.primaryGreen),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CatalogImage(
                              source: item.imageUrl,
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
                                if (distanceText != null) ...[
                                  const SizedBox(height: 4),
                                  _MetaLine(
                                    icon: Icons.my_location,
                                    text: '현재 위치에서 약 $distanceText',
                                  ),
                                ],
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
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(999),
                                onTap: () => launchPhoneDialer(
                                  context,
                                  item.phoneNumber,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.softGreen,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.phone_outlined,
                                        color: AppColors.primaryGreen,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          _displayInfo(
                                            item.phoneNumber,
                                            fallback: '전화번호 업데이트 예정',
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: AppColors.primaryGreen,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _openDetail(context, item),
                            icon: const Icon(
                              Icons.local_offer_outlined,
                              size: 17,
                            ),
                            label: const Text('특가 보기'),
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              foregroundColor: AppColors.primaryGreen,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
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
