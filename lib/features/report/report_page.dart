import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  int _selectedType = 0;

  @override
  Widget build(BuildContext context) {
    final reportTypes = [
      _ReportType('전단지', Icons.newspaper, '+100P'),
      _ReportType('특가 문자', Icons.sms_outlined, '+50P'),
      _ReportType('영수증 특가', Icons.receipt_long, '+100P'),
      _ReportType('매장 특가 사진', Icons.local_offer_outlined, '+80P'),
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          '우리 동네 좋은 특가를 알려주세요. 승인되면 포인트를 드려요.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 18),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reportTypes.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.18,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final type = reportTypes[index];
            final selected = _selectedType == index;
            return InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => setState(() => _selectedType = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected
                        ? Theme.of(context).colorScheme.primary
                        : AppColors.frame,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      type.icon,
                      size: 34,
                      color: selected
                          ? Theme.of(context).colorScheme.primary
                          : const Color(0xFF374151),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      type.title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: selected
                            ? Theme.of(context).colorScheme.primary
                            : AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Text(
                          type.points,
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : const Color(0xFF6B7280),
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 22),
        _UploadBox(type: reportTypes[_selectedType].title),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: '마트 이름',
            hintText: '예: 원주OO식자재마트',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          minLines: 3,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: '추가 메모',
            hintText: '행사 기간, 상품명, 특가 내용 등을 적어주세요.',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('특가 제보하기'),
        ),
        const SizedBox(height: 22),
        const _ReportStatusCard(),
      ],
    );
  }
}

class _ReportType {
  const _ReportType(this.title, this.icon, this.points);

  final String title;
  final IconData icon;
  final String points;
}

class _UploadBox extends StatelessWidget {
  const _UploadBox({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.frame, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 16),
        child: Column(
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 10),
            Text(
              '$type 사진 촬영/업로드',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            const Text(
              '검수 후 승인되면 포인트가 지급됩니다.',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportStatusCard extends StatelessWidget {
  const _ReportStatusCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(child: Icon(Icons.hourglass_top)),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '최근 특가 제보: 승인 대기',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 4),
                  Text('전단지 1건 · 예상 적립 100P'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
