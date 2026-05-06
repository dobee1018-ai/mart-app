import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../data/auth/auth_service.dart';
import '../../data/repositories/review_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../models/app_enums.dart';
import '../../models/mart_review.dart';
import '../../theme/app_colors.dart';
import '../review/review_moderation.dart';
import '../shared/mock_catalog.dart';
import '../shared/shopping_list_store.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final _authService = AuthService();
  final _userRepository = UserRepository();
  bool _authBusy = false;

  void _removeCartGroup(String martName) {
    ShoppingListStore.instance.removeCartGroup(martName);
  }

  void _removeCartLine(String martName, CartLine line) {
    ShoppingListStore.instance.removeCartLine(martName, line);
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _authBusy = true);
    try {
      final credential = await _authService.signInWithGoogle();
      final user = credential.user;
      if (user != null) {
        await _userRepository.saveSignedInUser(user);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그인되었습니다.')));
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('로그인에 실패했습니다. $error')));
    } finally {
      if (mounted) {
        setState(() => _authBusy = false);
      }
    }
  }

  Future<void> _signOut() async {
    setState(() => _authBusy = true);
    try {
      await _authService.signOut();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그아웃되었습니다.')));
    } finally {
      if (mounted) {
        setState(() => _authBusy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final menus = [
      _MyMenu(
        title: '이달의 소비 기록',
        icon: Icons.pie_chart_outline,
        page: const ExpenseDetailPage(),
      ),
      _MyMenu(
        title: '리뷰 작성',
        icon: Icons.rate_review_outlined,
        page: const ReviewDetailPage(),
      ),
      _MyMenu(
        title: '특가 제보 내역',
        icon: Icons.add_a_photo_outlined,
        page: const ReportHistoryPage(),
      ),
      _MyMenu(
        title: '포인트 상품권 교환',
        icon: Icons.card_giftcard,
        page: const PointExchangePage(),
      ),
      _MyMenu(
        title: '설정',
        icon: Icons.settings_outlined,
        page: const SettingsDetailPage(),
      ),
    ];

    return AnimatedBuilder(
      animation: ShoppingListStore.instance,
      builder: (context, child) {
        final cartGroups = ShoppingListStore.instance.cartGroups;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            StreamBuilder<User?>(
              stream: _authService.authStateChanges(),
              initialData: _authService.currentUser,
              builder: (context, snapshot) {
                return _ProfileCard(
                  user: snapshot.data,
                  isBusy: _authBusy,
                  onSignIn: _signInWithGoogle,
                  onSignOut: _signOut,
                );
              },
            ),
            const SizedBox(height: 18),
            _PointCard(
              onExchangeTap: () => _push(context, const PointExchangePage()),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    '마트별 장바구니',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _push(
                      context,
                      CartDetailPage(
                        cartGroups: cartGroups,
                        onRemoveGroup: _removeCartGroup,
                        onRemoveLine: _removeCartLine,
                      ),
                    );
                  },
                  child: const Text('전체보기'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _CartSummaryCard(
              cartGroups: cartGroups,
              onRemoveGroup: _removeCartGroup,
              onOpen: () {
                _push(
                  context,
                  CartDetailPage(
                    cartGroups: cartGroups,
                    onRemoveGroup: _removeCartGroup,
                    onRemoveLine: _removeCartLine,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    '이달의 소비 기록',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ),
                TextButton(
                  onPressed: () => _push(context, const ExpenseDetailPage()),
                  child: const Text('월별/일별'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _push(context, const ExpenseDetailPage()),
              child: _ReceiptSummaryCard(),
            ),
            const SizedBox(height: 18),
            ...menus.map(
              (menu) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
                child: ListTile(
                  leading: Icon(
                    menu.icon,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(menu.title),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _push(context, menu.page),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MyMenu {
  const _MyMenu({required this.title, required this.icon, required this.page});

  final String title;
  final IconData icon;
  final Widget page;
}

typedef CartGroup = ShoppingCartGroup;
typedef CartLine = ShoppingCartLine;

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.user,
    required this.isBusy,
    required this.onSignIn,
    required this.onSignOut,
  });

  final User? user;
  final bool isBusy;
  final VoidCallback onSignIn;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final displayName = user?.displayName?.trim();
    final email = user?.email?.trim();
    final photoURL = user?.photoURL;
    final signedIn = user != null;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundImage: photoURL == null ? null : NetworkImage(photoURL),
              child: photoURL == null
                  ? const Icon(Icons.person, color: Colors.white, size: 30)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    signedIn
                        ? '${displayName?.isNotEmpty == true ? displayName : '동네마트 회원'} 님'
                        : '로그인이 필요합니다',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    signedIn
                        ? '${email?.isNotEmpty == true ? email : 'Google 계정'} · 원주시'
                        : '장보기 메모와 장바구니를 저장할 수 있어요.',
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            FilledButton.tonalIcon(
              onPressed: isBusy ? null : (signedIn ? onSignOut : onSignIn),
              icon: isBusy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(signedIn ? Icons.logout : Icons.login),
              label: Text(signedIn ? '로그아웃' : '로그인'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PointCard extends StatelessWidget {
  const _PointCard({required this.onExchangeTap});

  final VoidCallback onExchangeTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [AppColors.freshGreen, AppColors.primaryGreen],
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('보유 포인트', style: TextStyle(color: Colors.white70)),
                SizedBox(height: 4),
                Text(
                  '12,500 P',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          FilledButton.tonal(onPressed: onExchangeTap, child: const Text('교환')),
        ],
      ),
    );
  }
}

class _CartSummaryCard extends StatelessWidget {
  const _CartSummaryCard({
    required this.cartGroups,
    required this.onRemoveGroup,
    required this.onOpen,
  });

  final List<CartGroup> cartGroups;
  final ValueChanged<String> onRemoveGroup;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    if (cartGroups.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: const Padding(
          padding: EdgeInsets.all(22),
          child: Center(child: Text('담은 상품이 없습니다.')),
        ),
      );
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              ...cartGroups.map(
                (group) => _CartRow(
                  group: group,
                  onRemove: () => onRemoveGroup(group.martName),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartRow extends StatelessWidget {
  const _CartRow({required this.group, required this.onRemove});

  final CartGroup group;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final items = group.items.map((line) => line.name).join(', ');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.storefront, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.martName,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(items, style: const TextStyle(color: Color(0xFF6B7280))),
              ],
            ),
          ),
          Text(
            _won(group.total),
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          IconButton(
            tooltip: '삭제',
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}

class _ReceiptSummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('이번 달 식비 총 지출'),
                      SizedBox(height: 4),
                      Text(
                        '₩342,500',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.trending_up,
                  color: Theme.of(context).colorScheme.error,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...receiptSummaries.map(
              (receipt) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(child: Text(receipt.date)),
                title: Text(receipt.martName),
                subtitle: Text(receipt.description),
                trailing: Text(
                  '-${_won(receipt.amount)}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartDetailPage extends StatefulWidget {
  const CartDetailPage({
    super.key,
    required this.cartGroups,
    required this.onRemoveGroup,
    required this.onRemoveLine,
  });

  final List<CartGroup> cartGroups;
  final ValueChanged<String> onRemoveGroup;
  final void Function(String martName, CartLine line) onRemoveLine;

  @override
  State<CartDetailPage> createState() => _CartDetailPageState();
}

class _CartDetailPageState extends State<CartDetailPage> {
  void _removeGroup(String martName) {
    widget.onRemoveGroup(martName);
    setState(() {});
  }

  void _removeLine(String martName, CartLine line) {
    widget.onRemoveLine(martName, line);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cartGroups = widget.cartGroups;
    final total = cartGroups.fold(0, (sum, group) => sum + group.total);
    return _DetailScaffold(
      title: '마트별 장바구니',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SummaryBanner(
            title: '총 예상 결제 금액',
            value: _won(total),
            subtitle: '${cartGroups.length}개 마트에 담긴 상품',
          ),
          const SizedBox(height: 18),
          if (cartGroups.isEmpty)
            const _EmptyCard(text: '담은 상품이 없습니다.')
          else
            ...cartGroups.map(
              (group) => Card(
                color: AppColors.surface,
                surfaceTintColor: AppColors.surface,
                elevation: 2,
                shadowColor: const Color(0x120F7A4B),
                margin: const EdgeInsets.only(bottom: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFDDEFE5)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.softGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: AppColors.surface,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.storefront,
                                size: 18,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                group.martName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textDark,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () => _removeGroup(group.martName),
                              icon: const Icon(Icons.delete_outline, size: 17),
                              label: const Text('삭제'),
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
                      ),
                      const SizedBox(height: 8),
                      ...group.items.map(
                        (line) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      line.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppColors.textDark,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${_won(line.price)} x ${line.quantity}',
                                      style: const TextStyle(
                                        color: AppColors.textGray,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _won(line.total),
                                style: const TextStyle(
                                  color: AppColors.textDark,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              IconButton(
                                tooltip: '상품 삭제',
                                onPressed: () =>
                                    _removeLine(group.martName, line),
                                icon: const Icon(Icons.close, size: 19),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Text(
                              '마트별 합계',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                            const Spacer(),
                            Text(
                              _won(group.total),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ExpenseDetailPage extends StatelessWidget {
  const ExpenseDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _DetailScaffold(
      title: '소비 기록',
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: '월별'),
                Tab(text: '일별'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [_MonthlyExpenseView(), _DailyExpenseView()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthlyExpenseView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const months = [
      ('2026년 4월', 342500, '+25,000'),
      ('2026년 3월', 317500, '-18,000'),
      ('2026년 2월', 335500, '+12,000'),
    ];
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _SummaryBanner(
          title: '2026년 4월 식비',
          value: '₩342,500',
          subtitle: '지난달 대비 ₩25,000 증가',
        ),
        const SizedBox(height: 18),
        ...months.map(
          (month) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              title: Text(month.$1),
              subtitle: Text('전월 대비 ${month.$3}'),
              trailing: Text(
                _won(month.$2),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DailyExpenseView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final days = [
      ('4.29', '엘마트', '돼지 앞다리살 외 3건', 36500),
      ('4.28', '행복한식자재마트 단구점', '계란 외 4건', 24500),
      ('4.24', '하나로마트 판부농협본점', '돼지고기 앞다리살 외 2건', 18200),
      ('4.20', '대륙식자재마트 원주본점', '식용유, 양파 외 2건', 42700),
    ];
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ...days.map(
          (day) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(child: Text(day.$1)),
              title: Text(day.$2),
              subtitle: Text(day.$3),
              trailing: Text(
                '-${_won(day.$4)}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ReviewDetailPage extends StatefulWidget {
  const ReviewDetailPage({
    super.key,
    this.initialTarget,
    this.targetType = ReviewTargetType.mart,
  });

  final String? initialTarget;
  final ReviewTargetType? targetType;

  @override
  State<ReviewDetailPage> createState() => _ReviewDetailPageState();
}

class _ReviewDetailPageState extends State<ReviewDetailPage> {
  final _reviewController = TextEditingController();
  final _reviewRepository = ReviewRepository();
  late String _selectedTarget;
  int _rating = 4;
  ReviewModerationResult? _moderationResult;
  bool _isSubmitting = false;

  ReviewTargetType get _targetType =>
      widget.targetType ?? ReviewTargetType.mart;

  @override
  void initState() {
    super.initState();
    _selectedTarget = widget.initialTarget ?? _targetOptions.first;
  }

  List<String> get _targetOptions {
    if (_targetType == ReviewTargetType.product) {
      return [_selectedTargetOrFallback];
    }
    final options = flyerItems.map((item) => item.martName).toSet().toList();
    final initialTarget = widget.initialTarget;
    if (initialTarget != null && !options.contains(initialTarget)) {
      options.insert(0, initialTarget);
    }
    return options;
  }

  String get _selectedTargetOrFallback => widget.initialTarget ?? '상품을 선택해주세요';

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    final result = ReviewModeration.check(_reviewController.text);
    setState(() => _moderationResult = result);

    if (!result.canSubmit) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그인 후 리뷰를 작성할 수 있어요.')));
      return;
    }

    final statusText = switch (result.status) {
      ReviewModerationStatus.scheduled => '24시간 검토 대기 후 공개 예정입니다.',
      ReviewModerationStatus.needsReview => '관리자 확인 후 공개됩니다.',
      ReviewModerationStatus.blocked => '',
    };

    setState(() => _isSubmitting = true);
    try {
      final now = DateTime.now();
      final displayName = user.displayName?.trim();
      await _reviewRepository.createReview(
        MartReview(
          id: '',
          userId: user.uid,
          userNickname: displayName?.isNotEmpty == true
              ? displayName!
              : '동네마트 회원',
          targetType: _targetType,
          targetName: _selectedTarget,
          rating: _rating,
          content: _reviewController.text.trim(),
          status: result.status == ReviewModerationStatus.needsReview
              ? ReviewStatus.needsReview
              : ReviewStatus.scheduled,
          createdAt: now,
          publishAt: now.add(result.publishAfter),
          moderationFlags: result.flags,
        ),
      );

      if (!mounted) return;
      _reviewController.clear();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('리뷰가 접수되었습니다. $statusText')));
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('리뷰 접수에 실패했습니다. $error')));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final targetType = _targetType;
    final isProductReview = targetType == ReviewTargetType.product;
    final options = _targetOptions;
    return _DetailScaffold(
      title: targetType.label,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (isProductReview)
            _SelectedReviewTargetCard(
              icon: Icons.inventory_2_outlined,
              label: '상품 리뷰 대상',
              targetName: _selectedTarget,
            )
          else
            DropdownButtonFormField<String>(
              initialValue: _selectedTarget,
              decoration: const InputDecoration(labelText: '리뷰할 마트 선택'),
              items: options
                  .map(
                    (martName) => DropdownMenuItem(
                      value: martName,
                      child: Text(martName),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedTarget = value);
              },
            ),
          const SizedBox(height: 18),
          const Text('별점', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              final active = index < _rating;
              return IconButton(
                onPressed: () => setState(() => _rating = index + 1),
                icon: Icon(active ? Icons.star : Icons.star_border),
                color: AppColors.accentOrange,
              );
            }),
          ),
          const SizedBox(height: 12),
          _UploadBox(label: '사진 추가'),
          const SizedBox(height: 12),
          _ReviewPolicyNotice(result: _moderationResult),
          const SizedBox(height: 12),
          TextField(
            controller: _reviewController,
            minLines: 5,
            maxLines: 7,
            decoration: InputDecoration(
              labelText: '리뷰 내용',
              hintText: isProductReview
                  ? '품질, 신선도, 가격 만족도 등 상품 후기를 남겨주세요.'
                  : '신선도, 가격, 서비스 등 마트 이용 후기를 남겨주세요.',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _isSubmitting ? null : _submitReview,
            icon: _isSubmitting
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.rate_review_outlined),
            label: Text(_isSubmitting ? '접수 중' : '검토 요청하기'),
          ),
        ],
      ),
    );
  }
}

class _ReviewPolicyNotice extends StatelessWidget {
  const _ReviewPolicyNotice({required this.result});

  final ReviewModerationResult? result;

  @override
  Widget build(BuildContext context) {
    final blocked = result?.status == ReviewModerationStatus.blocked;
    final needsReview = result?.status == ReviewModerationStatus.needsReview;
    final color = blocked
        ? AppColors.danger
        : needsReview
        ? AppColors.accentOrange
        : AppColors.primaryGreen;
    final background = blocked
        ? const Color(0xFFFFEFEA)
        : needsReview
        ? AppColors.softOrange
        : AppColors.softGreen;
    final message = result?.message ?? '리뷰는 바로 공개되지 않고 24시간 검토 대기 후 공개됩니다.';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  blocked ? Icons.block : Icons.verified_user_outlined,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(color: color, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            if (result?.flags.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: result!.flags.map((flag) {
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: color.withValues(alpha: 0.22)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Text(
                        flag,
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SelectedReviewTargetCard extends StatelessWidget {
  const _SelectedReviewTargetCard({
    required this.icon,
    required this.label,
    required this.targetName,
  });

  final IconData icon;
  final String label;
  final String targetName;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.frame),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.softGreen,
              foregroundColor: AppColors.primaryGreen,
              child: Icon(icon),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textGray,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    targetName,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
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

class ReportHistoryPage extends StatelessWidget {
  const ReportHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    const reports = [
      ('전단지', '대륙식자재마트 원주본점', '승인 대기', '+100P 예정'),
      ('영수증', '행복한식자재마트 단구점', '승인 완료', '+100P 적립'),
      ('매장 특가 사진', '엘마트 개운점', '수정 요청', '특가 내용 식별 필요'),
    ];
    return _DetailScaffold(
      title: '특가 제보 내역',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const _SummaryBanner(
            title: '이번 달 특가 제보',
            value: '3건',
            subtitle: '승인 완료 1건 · 승인 대기 1건 · 수정 요청 1건',
          ),
          const SizedBox(height: 18),
          ...reports.map(
            (report) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.camera_alt_outlined),
                ),
                title: Text('${report.$1} · ${report.$2}'),
                subtitle: Text(report.$4),
                trailing: _StatusPill(text: report.$3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PointExchangePage extends StatelessWidget {
  const PointExchangePage({super.key});

  @override
  Widget build(BuildContext context) {
    const gifts = [
      ('네이버페이 포인트 5,000원', 5000),
      ('네이버페이 포인트 10,000원', 10000),
      ('동네마트 상품권 5,000원', 5000),
    ];
    return _DetailScaffold(
      title: '포인트 교환',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const _SummaryBanner(
            title: '현재 보유 포인트',
            value: '12,500 P',
            subtitle: '5,000P부터 교환 신청 가능',
          ),
          const SizedBox(height: 18),
          ...gifts.map(
            (gift) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.card_giftcard)),
                title: Text(gift.$1),
                subtitle: const Text('관리자 확인 후 순차 발급'),
                trailing: FilledButton(
                  onPressed: () {},
                  child: Text('${gift.$2}P'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsDetailPage extends StatelessWidget {
  const SettingsDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _DetailScaffold(
      title: '설정',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SwitchListTile(
            value: true,
            onChanged: (_) {},
            title: const Text('장보기 메모 특가 알림'),
            subtitle: const Text('메모 상품이 특가로 올라오면 알려드려요.'),
          ),
          SwitchListTile(
            value: true,
            onChanged: (_) {},
            title: const Text('특가 제보 승인/포인트 알림'),
            subtitle: const Text('특가 제보 검수 결과와 포인트 적립을 알려드려요.'),
          ),
          SwitchListTile(
            value: false,
            onChanged: (_) {},
            title: const Text('위치 기반 추천'),
            subtitle: const Text('현재 위치 기준 가까운 마트를 우선 표시합니다.'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text('기본 지역'),
            subtitle: const Text('강원도 원주시'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.login),
            title: const Text('로그인 계정'),
            subtitle: const Text('Google / Apple / Kakao / Naver 연동 예정'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _DetailScaffold extends StatelessWidget {
  const _DetailScaffold({required this.title, required this.child});

  final String title;
  final Widget child;

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
              title: Text(title),
            ),
            body: child,
          ),
        ),
      ),
    );
  }
}

class _SummaryBanner extends StatelessWidget {
  const _SummaryBanner({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(title, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class _UploadBox extends StatelessWidget {
  const _UploadBox({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.frame),
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.add_a_photo_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 38,
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(child: Text(text)),
      ),
    );
  }
}

void _push(BuildContext context, Widget page) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (context) => page));
}

String _won(int value) =>
    '₩${value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',')}';
