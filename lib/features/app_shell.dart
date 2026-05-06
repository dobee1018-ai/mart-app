import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/auth/auth_service.dart';
import '../data/repositories/user_repository.dart';
import '../firebase/firebase_bootstrap.dart';
import '../models/app_enums.dart';
import '../theme/app_colors.dart';
import 'admin/admin_review_page.dart';
import 'marts/marts_page.dart';
import 'memo/memo_page.dart';
import 'my/my_page.dart';
import 'recipe/recipe_page.dart';
import 'report/report_page.dart';
import 'search/search_page.dart';
import 'shared/shopping_list_store.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.firebaseStatus});

  final FirebaseBootstrapStatus firebaseStatus;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _authService = AuthService();
  final _userRepository = UserRepository();
  int _selectedIndex = 0;
  bool _showReport = false;
  bool _showAdmin = false;

  @override
  void initState() {
    super.initState();
    if (widget.firebaseStatus == FirebaseBootstrapStatus.ready) {
      ShoppingListStore.instance.bindAuthState(_authService.authStateChanges());
    }
  }

  List<Widget> get _pages => [
    SearchPage(onReportTap: _openReport),
    const MartsPage(),
    const RecipePage(),
    const MemoPage(),
    const MyPage(),
  ];

  void _openReport() {
    setState(() => _showReport = true);
  }

  void _openAdmin() {
    setState(() => _showAdmin = true);
  }

  @override
  Widget build(BuildContext context) {
    final titles = [
      '오늘의 동네마트 특가',
      '우리 동네 마트',
      '오늘 저녁 뭐 먹지?',
      '장보기 메모',
      '마이페이지',
    ];
    final showReportAction = _selectedIndex == 0 || _selectedIndex == 1;

    if (_showAdmin) {
      return _PhoneFrame(
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              tooltip: '뒤로',
              onPressed: () => setState(() => _showAdmin = false),
              icon: const Icon(Icons.chevron_left),
            ),
            title: const Text('관리자 제보 검토'),
          ),
          body: Column(
            children: [
              if (widget.firebaseStatus ==
                  FirebaseBootstrapStatus.missingConfiguration)
                const _FirebaseConfigNotice(),
              const Expanded(child: AdminReviewPage()),
            ],
          ),
        ),
      );
    }

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
              _AdminAction(
                authService: _authService,
                userRepository: _userRepository,
                onOpenAdmin: _openAdmin,
              ),
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
            _AdminAction(
              authService: _authService,
              userRepository: _userRepository,
              onOpenAdmin: _openAdmin,
            ),
            if (showReportAction)
              IconButton(
                tooltip: '특가 제보',
                onPressed: _openReport,
                icon: const Icon(Icons.add_a_photo_outlined),
              ),
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
        bottomNavigationBar: DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
            boxShadow: [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 18,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: NavigationBar(
            height: 70,
            indicatorShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
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
                icon: Icon(Icons.restaurant_menu_outlined),
                selectedIcon: Icon(Icons.restaurant_menu),
                label: '레시피',
              ),
              NavigationDestination(
                icon: Icon(Icons.edit_note_outlined),
                selectedIcon: Icon(Icons.edit_note),
                label: '메모',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: '내 정보',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminAction extends StatelessWidget {
  const _AdminAction({
    required this.authService,
    required this.userRepository,
    required this.onOpenAdmin,
  });

  final AuthService authService;
  final UserRepository userRepository;
  final VoidCallback onOpenAdmin;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: authService.authStateChanges(),
      initialData: authService.currentUser,
      builder: (context, authSnapshot) {
        final user = authSnapshot.data;
        if (user == null) return const SizedBox.shrink();

        return StreamBuilder<UserRole>(
          stream: userRepository.watchUserRole(user.uid),
          builder: (context, roleSnapshot) {
            final role = roleSnapshot.data;
            if (role != UserRole.admin) return const SizedBox.shrink();

            return IconButton(
              tooltip: '관리자 제보 검토',
              onPressed: onOpenAdmin,
              icon: const Icon(Icons.admin_panel_settings_outlined),
            );
          },
        );
      },
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
