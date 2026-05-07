import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme/app_colors.dart';
import 'app_snack_bar.dart';
import 'mock_catalog.dart';

Future<void> showMapLauncherSheet(
  BuildContext context, {
  required String martName,
  String? address,
}) {
  final query = [
    martName,
    if (address != null && address.trim().isNotEmpty) address.trim(),
  ].join(' ');

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '어떤 지도로 안내할까요?',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              martName,
              style: const TextStyle(
                color: AppColors.textGray,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            _MapOptionTile(
              icon: Icons.map_outlined,
              title: '네이버지도',
              subtitle: '상호와 주소를 네이버지도에서 검색합니다.',
              onTap: () => _openMapAndClose(
                context,
                appUri: Uri.parse(
                  'nmap://search?query=${Uri.encodeComponent(query)}&appname=wonju_mart_app',
                ),
                fallbackUri: Uri.parse(
                  'https://map.naver.com/p/search/${Uri.encodeComponent(query)}',
                ),
              ),
            ),
            _MapOptionTile(
              icon: Icons.location_on_outlined,
              title: '카카오맵',
              subtitle: '카카오맵에서 마트 위치를 검색합니다.',
              onTap: () => _openMapAndClose(
                context,
                appUri: Uri.parse(
                  'kakaomap://search?q=${Uri.encodeComponent(query)}',
                ),
                fallbackUri: Uri.parse(
                  'https://map.kakao.com/link/search/${Uri.encodeComponent(query)}',
                ),
              ),
            ),
            _MapOptionTile(
              icon: Icons.navigation_outlined,
              title: '티맵',
              subtitle: '차량 길찾기용 티맵 검색을 엽니다.',
              onTap: () => _openMapAndClose(
                context,
                appUri: Uri.parse(
                  'tmap://search?name=${Uri.encodeComponent(query)}',
                ),
                fallbackUri: Uri.parse(
                  'https://www.google.com/search?q=${Uri.encodeComponent('티맵 $query')}',
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> launchPhoneDialer(BuildContext context, String phoneNumber) async {
  final cleaned = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
  if (cleaned.isEmpty || phoneNumber.contains('정보 없음')) {
    showTimedSnackBar(context, message: '전화번호가 준비 중입니다.');
    return;
  }

  final uri = Uri(scheme: 'tel', path: cleaned);
  try {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (opened) return;
  } catch (_) {
    // Fall through to the user-facing message below.
  }

  if (context.mounted) {
    showTimedSnackBar(context, message: '이 기기에서는 전화 앱을 열 수 없습니다.');
  }
}

FlyerItem? findFlyerByMartName(String martName) {
  return flyerItems.where((item) => item.martName == martName).firstOrNull;
}

Future<void> _openMapAndClose(
  BuildContext context, {
  required Uri appUri,
  required Uri fallbackUri,
}) async {
  Navigator.of(context).pop();
  var opened = false;
  try {
    opened = await launchUrl(appUri, mode: LaunchMode.externalApplication);
  } catch (_) {
    opened = false;
  }

  if (!opened) {
    final fallbackOpened = await launchUrl(
      fallbackUri,
      mode: LaunchMode.externalApplication,
    );
    if (!fallbackOpened && context.mounted) {
      showTimedSnackBar(context, message: '지도 앱을 열 수 없습니다.');
    }
  }
}

class _MapOptionTile extends StatelessWidget {
  const _MapOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.softGreen,
          foregroundColor: AppColors.primaryGreen,
          child: Icon(icon),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
