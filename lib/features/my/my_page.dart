import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../shared/mock_catalog.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final List<CartGroup> _cartGroups = [
    CartGroup(
      martName: '행복한식자재마트 단구점',
      items: [CartLine('계란 30구', 6900, 1), CartLine('맛있는 우유 900ml', 1980, 1)],
    ),
    CartGroup(
      martName: '상지식자재할인마트',
      items: [CartLine('양파 15kg/망', 12000, 1), CartLine('감자 3kg 박스', 6800, 1)],
    ),
  ];

  void _removeCartGroup(String martName) {
    setState(() {
      _cartGroups.removeWhere((group) => group.martName == martName);
    });
  }

  void _removeCartLine(String martName, CartLine line) {
    setState(() {
      final group = _cartGroups
          .where((group) => group.martName == martName)
          .firstOrNull;
      if (group == null) return;
      group.items.remove(line);
      if (group.items.isEmpty) {
        _cartGroups.remove(group);
      }
    });
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

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _ProfileCard(),
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
                    cartGroups: _cartGroups,
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
          cartGroups: _cartGroups,
          onRemoveGroup: _removeCartGroup,
          onOpen: () {
            _push(
              context,
              CartDetailPage(
                cartGroups: _cartGroups,
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
  }
}

class _MyMenu {
  const _MyMenu({required this.title, required this.icon, required this.page});

  final String title;
  final IconData icon;
  final Widget page;
}

class CartGroup {
  CartGroup({required this.martName, required this.items});

  final String martName;
  final List<CartLine> items;

  int get total => items.fold(0, (sum, item) => sum + item.total);
}

class CartLine {
  CartLine(this.name, this.price, this.quantity);

  final String name;
  final int price;
  final int quantity;

  int get total => price * quantity;
}

class _ProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.person, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '절약왕 김주부 님',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                  SizedBox(height: 4),
                  Text('원주시 · 우수 특가 제보자 등급'),
                ],
              ),
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
                margin: const EdgeInsets.only(bottom: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.storefront,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              group.martName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 17,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _removeGroup(group.martName),
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: const Text('마트 삭제'),
                          ),
                        ],
                      ),
                      const Divider(),
                      ...group.items.map(
                        (line) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(line.name),
                          subtitle: Text(
                            '${_won(line.price)} x ${line.quantity}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _won(line.total),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              IconButton(
                                tooltip: '상품 삭제',
                                onPressed: () =>
                                    _removeLine(group.martName, line),
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(),
                      Row(
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
  const ReviewDetailPage({super.key});

  @override
  State<ReviewDetailPage> createState() => _ReviewDetailPageState();
}

class _ReviewDetailPageState extends State<ReviewDetailPage> {
  int _rating = 4;

  @override
  Widget build(BuildContext context) {
    return _DetailScaffold(
      title: '리뷰 작성',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          DropdownButtonFormField<String>(
            initialValue: '행복한식자재마트 단구점',
            decoration: const InputDecoration(labelText: '마트 또는 상품 선택'),
            items: const [
              DropdownMenuItem(
                value: '행복한식자재마트 단구점',
                child: Text('행복한식자재마트 단구점'),
              ),
              DropdownMenuItem(
                value: '대륙식자재마트 원주본점',
                child: Text('대륙식자재마트 원주본점'),
              ),
              DropdownMenuItem(value: '계란 30구', child: Text('계란 30구')),
            ],
            onChanged: (_) {},
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
          const TextField(
            minLines: 5,
            maxLines: 7,
            decoration: InputDecoration(
              labelText: '리뷰 내용',
              hintText: '신선도, 가격, 서비스 등 솔직한 리뷰를 남겨주세요.',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(onPressed: () {}, child: const Text('등록하기')),
        ],
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
