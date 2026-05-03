import 'package:flutter/material.dart';

import '../firebase/firebase_bootstrap.dart';
import '../theme/app_colors.dart';
import 'community/community_page.dart';
import 'marts/marts_page.dart';
import 'memo/memo_page.dart';
import 'my/my_page.dart';
import 'recipe/recipe_page.dart';
import 'report/report_page.dart';
import 'search/search_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.firebaseStatus});

  final FirebaseBootstrapStatus firebaseStatus;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  bool _showReport = false;

  List<Widget> get _pages => [
    SearchPage(onReportTap: _openReport),
    const MartsPage(),
    const CommunityPage(),
    const RecipePage(),
    const MemoPage(),
    const MyPage(),
  ];

  void _openReport() {
    setState(() => _showReport = true);
  }

  @override
  Widget build(BuildContext context) {
    final titles = [
      '오늘의 동네마트 특가',
      '우리 동네 마트',
      '우리 동네 소분모임',
      '오늘 저녁 뭐 먹지?',
      '장보기 메모',
      '마이페이지',
    ];

    if (_showReport) {
      return _PhoneFrame(
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              tooltip: '뒤로',
              onPressed: () => setState(() => _showReport = false),
              icon: const Icon(Icons.chevron_left),
            ),
            title: const Text('특가 제보'),
            actions: [
              IconButton(
                tooltip: '알림',
                onPressed: () {},
                icon: const Icon(Icons.notifications_none),
              ),
            ],
          ),
          body: Column(
            children: [
              if (widget.firebaseStatus ==
                  FirebaseBootstrapStatus.missingConfiguration)
                const _FirebaseConfigNotice(),
              const Expanded(child: ReportPage()),
            ],
          ),
        ),
      );
    }

    return _PhoneFrame(
      child: Scaffold(
        appBar: AppBar(
          title: Text(titles[_selectedIndex]),
          actions: [
            IconButton(
              tooltip: '알림',
              onPressed: () {},
              icon: const Icon(Icons.notifications_none),
            ),
          ],
        ),
        body: Column(
          children: [
            if (widget.firebaseStatus ==
                FirebaseBootstrapStatus.missingConfiguration)
              const _FirebaseConfigNotice(),
            Expanded(child: _pages[_selectedIndex]),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          height: 70,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: '홈',
            ),
            NavigationDestination(
              icon: Icon(Icons.newspaper_outlined),
              selectedIcon: Icon(Icons.newspaper),
              label: '동네마트',
            ),
            NavigationDestination(
              icon: Icon(Icons.groups_outlined),
              selectedIcon: Icon(Icons.groups),
              label: '소분모임',
            ),
            NavigationDestination(
              icon: Icon(Icons.restaurant_menu),
              label: '레시피',
            ),
            NavigationDestination(icon: Icon(Icons.edit_note), label: '메모'),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: '마이',
            ),
          ],
        ),
        floatingActionButton: _selectedIndex == 0
            ? FloatingActionButton.extended(
                onPressed: _openReport,
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('특가 제보'),
              )
            : null,
      ),
    );
  }
}

class _PhoneFrame extends StatelessWidget {
  const _PhoneFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.frame,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              boxShadow: [BoxShadow(color: Color(0x22000000), blurRadius: 24)],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _FirebaseConfigNotice extends StatelessWidget {
  const _FirebaseConfigNotice();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.softOrange,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.accentOrange),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Firebase 설정 파일 연결 전입니다. 현재는 마이그레이션용 UI/모델 구조로 동작합니다.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
