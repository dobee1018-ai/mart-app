import 'package:flutter/material.dart';

import '../../data/auth/auth_service.dart';
import '../../data/repositories/report_repository.dart';
import '../../models/app_enums.dart';
import '../../models/report.dart';
import '../../theme/app_colors.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final _authService = AuthService();
  final _reportRepository = ReportRepository();
  final _martNameController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageMemoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int _selectedType = 0;
  bool _isSubmitting = false;

  static const _reportTypes = [
    _ReportType(
      '전단지',
      ReportType.flyer,
      Icons.newspaper,
      '행사 후보',
      '행사 기간이 보이는 전단지 사진이 가장 좋아요.',
    ),
    _ReportType(
      '특가 문자',
      ReportType.sms,
      Icons.sms_outlined,
      '문자 확인',
      '상품명, 가격, 기간이 보이는 캡처를 권장해요.',
    ),
    _ReportType(
      '영수증 확인',
      ReportType.receipt,
      Icons.receipt_long,
      '구매 검증',
      '카드번호, 승인번호 등 개인정보는 가려주세요.',
    ),
    _ReportType(
      '매장 특가 사진',
      ReportType.priceTag,
      Icons.local_offer_outlined,
      '현장 확인',
      '상품과 가격표가 함께 보이면 승인에 유리해요.',
    ),
  ];

  @override
  void dispose() {
    _martNameController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _imageMemoController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    final user = _authService.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그인 후 특가를 제보할 수 있어요.')));
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);
    try {
      final type = _reportTypes[_selectedType];
      final imageLines = _imageMemoController.text
          .split(RegExp(r'[\n,]'))
          .map((line) => line.trim())
          .where((line) => line.startsWith('http'))
          .toList();

      await _reportRepository.createReport(
        Report(
          id: '',
          reporterId: user.uid,
          reporterNickname: user.displayName ?? user.email ?? '동네 제보자',
          type: type.value,
          approvalStatus: ApprovalStatus.pending,
          createdAt: DateTime.now(),
          martName: _martNameController.text.trim(),
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          imageUrls: imageLines,
          inputItems: [
            {
              'sourceMemo': _imageMemoController.text.trim(),
              'verificationHint': type.badge,
            },
          ],
        ),
      );

      _titleController.clear();
      _descriptionController.clear();
      _imageMemoController.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('특가 제보가 접수되었습니다. 관리자 검토 후 노출돼요.')),
      );
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('제보 저장에 실패했습니다. $error')));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          '우리 동네 좋은 특가를 알려주세요. 정확한 제보는 검토 후 앱에 노출되고 주간 우수 제보 선정에 반영돼요.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 18),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _reportTypes.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.18,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final type = _reportTypes[index];
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
                          type.badge,
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
        _UploadBox(type: _reportTypes[_selectedType]),
        const SizedBox(height: 16),
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _martNameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '마트 이름을 입력해주세요.';
                  }
                  return null;
                },
                decoration: _fieldDecoration(
                  label: '마트 이름',
                  hint: '예: 대륙식자재마트 원주본점',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '대표 상품명이나 제보 제목을 입력해주세요.';
                  }
                  return null;
                },
                decoration: _fieldDecoration(
                  label: '대표 상품명/제목',
                  hint: '예: 양파 3kg 2,980원',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                minLines: 3,
                maxLines: 5,
                decoration: _fieldDecoration(
                  label: '특가 내용',
                  hint: '행사 기간, 가격, 용량, 수량 한정 여부 등을 적어주세요.',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _imageMemoController,
                minLines: 2,
                maxLines: 4,
                decoration: _fieldDecoration(
                  label: '사진 메모/링크',
                  hint: '사진 업로드 연결 전까지는 사진 설명이나 테스트 이미지 URL을 적어주세요.',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: _isSubmitting ? null : _submitReport,
          icon: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check_circle_outline),
          label: Text(_isSubmitting ? '접수 중' : '특가 제보하기'),
        ),
        const SizedBox(height: 22),
        const _ReportStatusCard(),
      ],
    );
  }

  InputDecoration _fieldDecoration({
    required String label,
    required String hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}

class _ReportType {
  const _ReportType(
    this.title,
    this.value,
    this.icon,
    this.badge,
    this.helperText,
  );

  final String title;
  final ReportType value;
  final IconData icon;
  final String badge;
  final String helperText;
}

class _UploadBox extends StatelessWidget {
  const _UploadBox({required this.type});

  final _ReportType type;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.frame, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        child: Column(
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 10),
            Text(
              '${type.title} 사진 촬영/업로드',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.softGreen,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFBFE8D2)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                child: Text(
                  type.badge,
                  style: const TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              type.helperText,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
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
                    '제보 상태: 관리자 검토 후 노출',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 4),
                  Text('승인된 제보는 닉네임과 인증 배지가 함께 표시됩니다.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
