import 'package:flutter/material.dart';

import '../../data/repositories/report_repository.dart';
import '../../models/app_enums.dart';
import '../../models/report.dart';
import '../../theme/app_colors.dart';

class AdminReviewPage extends StatefulWidget {
  const AdminReviewPage({super.key});

  @override
  State<AdminReviewPage> createState() => _AdminReviewPageState();
}

class _AdminReviewPageState extends State<AdminReviewPage> {
  final _repository = ReportRepository();
  _ReviewBucket _selectedBucket = _ReviewBucket.recommended;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Report>>(
      stream: _repository.watchAdminReports(),
      builder: (context, snapshot) {
        final reports = snapshot.data ?? const <Report>[];
        final groups = _buildCandidateGroups(reports);
        final counts = {
          for (final bucket in _ReviewBucket.values)
            bucket: groups.where((group) => group.bucket == bucket).length,
        };
        final filtered = groups
            .where((group) => group.bucket == _selectedBucket)
            .toList();

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (groups.isEmpty) {
          return const _EmptyReviewState();
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _ReviewDashboard(groups: groups),
            const SizedBox(height: 16),
            _BucketSelector(
              selected: _selectedBucket,
              counts: counts,
              onSelected: (bucket) {
                setState(() => _selectedBucket = bucket);
              },
            ),
            const SizedBox(height: 16),
            if (filtered.isEmpty)
              _EmptyBucketState(bucket: _selectedBucket)
            else
              ...filtered.map(
                (group) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CandidateGroupCard(
                    group: group,
                    repository: _repository,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ReviewDashboard extends StatelessWidget {
  const _ReviewDashboard({required this.groups});

  final List<_CandidateGroup> groups;

  @override
  Widget build(BuildContext context) {
    final recommended = groups
        .where((group) => group.bucket == _ReviewBucket.recommended)
        .length;
    final needsWork = groups
        .where(
          (group) =>
              group.bucket == _ReviewBucket.infoMissing ||
              group.bucket == _ReviewBucket.autoHold,
        )
        .length;
    final duplicate = groups
        .where((group) => group.bucket == _ReviewBucket.duplicate)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '자동 정리된 특가 후보',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        const Text(
          '제보를 마트/상품/가격 기준으로 묶고, 품질 점수와 위험 신호를 먼저 계산했어요.',
          style: TextStyle(
            color: AppColors.textGray,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _DashboardTile(
                label: '승인 추천',
                value: '$recommended',
                color: AppColors.primaryGreen,
                icon: Icons.verified_outlined,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: _DashboardTile(
                label: '확인 필요',
                value: '$needsWork',
                color: AppColors.accentOrange,
                icon: Icons.warning_amber_outlined,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: _DashboardTile(
                label: '중복 의심',
                value: '$duplicate',
                color: const Color(0xFF64748B),
                icon: Icons.merge_type,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DashboardTile extends StatelessWidget {
  const _DashboardTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
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

class _BucketSelector extends StatelessWidget {
  const _BucketSelector({
    required this.selected,
    required this.counts,
    required this.onSelected,
  });

  final _ReviewBucket selected;
  final Map<_ReviewBucket, int> counts;
  final ValueChanged<_ReviewBucket> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _ReviewBucket.values.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final bucket = _ReviewBucket.values[index];
          final active = selected == bucket;
          return ChoiceChip(
            selected: active,
            showCheckmark: false,
            onSelected: (_) => onSelected(bucket),
            label: Text('${bucket.label} ${counts[bucket] ?? 0}'),
            selectedColor: AppColors.primaryGreen,
            backgroundColor: AppColors.surface,
            side: BorderSide(
              color: active ? AppColors.primaryGreen : AppColors.frame,
            ),
            labelStyle: TextStyle(
              color: active ? AppColors.surface : AppColors.textGray,
              fontWeight: FontWeight.w900,
            ),
          );
        },
      ),
    );
  }
}

class _CandidateGroupCard extends StatelessWidget {
  const _CandidateGroupCard({required this.group, required this.repository});

  final _CandidateGroup group;
  final ReportRepository repository;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shadowColor: const Color(0x12000000),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: group.tone.background,
                    child: Icon(group.tone.icon, color: group.tone.foreground),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.productTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${group.martName} · ${group.priceText}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textGray,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _ScoreBadge(score: group.score),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  _MetaChip(
                    icon: Icons.description_outlined,
                    text: '제보 ${group.reports.length}건',
                  ),
                  _MetaChip(
                    icon: Icons.people_alt_outlined,
                    text: '제보자 ${group.reporterCount}명',
                  ),
                  ...group.sourceSummary.map(
                    (source) => _MetaChip(icon: source.icon, text: source.text),
                  ),
                ],
              ),
              if (group.riskFlags.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: group.riskFlags.take(3).map((flag) {
                    return _RiskChip(text: flag);
                  }).toList(),
                ),
              ],
              const SizedBox(height: 13),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      group.recommendReason,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textGray,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.tonal(
                    onPressed: () => _openDetail(context),
                    child: const Text('상세 검토'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return _CandidateDetailSheet(group: group, repository: repository);
      },
    );
  }
}

class _CandidateDetailSheet extends StatefulWidget {
  const _CandidateDetailSheet({required this.group, required this.repository});

  final _CandidateGroup group;
  final ReportRepository repository;

  @override
  State<_CandidateDetailSheet> createState() => _CandidateDetailSheetState();
}

class _CandidateDetailSheetState extends State<_CandidateDetailSheet> {
  late final TextEditingController _martController;
  late final TextEditingController _titleController;
  late final TextEditingController _priceController;
  late final TextEditingController _memoController;
  bool _homeVisible = true;
  bool _martVisible = false;
  final Set<String> _selectedBadges = {'관리자 승인'};
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _martController = TextEditingController(text: widget.group.martName);
    _titleController = TextEditingController(text: widget.group.productTitle);
    _priceController = TextEditingController(text: widget.group.priceText);
    _memoController = TextEditingController(text: widget.group.recommendReason);
    _selectedBadges.addAll(widget.group.suggestedBadges);
  }

  @override
  void dispose() {
    _martController.dispose();
    _titleController.dispose();
    _priceController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _updateGroup(ApprovalStatus status) async {
    setState(() => _busy = true);
    try {
      final memo =
          '대표정보: ${_martController.text.trim()} / ${_titleController.text.trim()} / ${_priceController.text.trim()}\n'
          '노출: 홈=$_homeVisible, 동네마트=$_martVisible\n'
          '배지: ${_selectedBadges.join(', ')}\n'
          '메모: ${_memoController.text.trim()}';

      for (final report in widget.group.reports) {
        await widget.repository.updateStatus(
          reportId: report.report.id,
          status: status,
          rewardPoint: 0,
          adminMemo: memo,
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${widget.group.productTitle} 후보를 ${status.label} 처리했습니다.',
          ),
        ),
      );
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('처리에 실패했습니다. $error')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      builder: (context, scrollController) {
        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.frame,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.group.productTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                _ScoreBadge(score: widget.group.score),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              widget.group.recommendReason,
              style: const TextStyle(
                color: AppColors.textGray,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 18),
            _DetailSection(
              title: '대표 정보 정리',
              child: Column(
                children: [
                  _AdminField(label: '마트명', controller: _martController),
                  const SizedBox(height: 10),
                  _AdminField(label: '상품명', controller: _titleController),
                  const SizedBox(height: 10),
                  _AdminField(label: '가격/용량', controller: _priceController),
                  const SizedBox(height: 10),
                  _AdminField(
                    label: '관리자 메모',
                    controller: _memoController,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _DetailSection(
              title: '노출 위치',
              child: Column(
                children: [
                  SwitchListTile(
                    value: _homeVisible,
                    onChanged: (value) => setState(() => _homeVisible = value),
                    title: const Text('홈 특가 상품으로 노출'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    value: _martVisible,
                    onChanged: (value) => setState(() => _martVisible = value),
                    title: const Text('동네마트 전단지/마트 상세에 연결'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _DetailSection(
              title: '인증 배지',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _badgeOptions.map((badge) {
                  final selected = _selectedBadges.contains(badge);
                  return FilterChip(
                    label: Text(badge),
                    selected: selected,
                    showCheckmark: false,
                    selectedColor: AppColors.softGreen,
                    side: BorderSide(
                      color: selected
                          ? AppColors.primaryGreen
                          : AppColors.frame,
                    ),
                    labelStyle: TextStyle(
                      color: selected
                          ? AppColors.primaryGreen
                          : AppColors.textGray,
                      fontWeight: FontWeight.w900,
                    ),
                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          _selectedBadges.add(badge);
                        } else {
                          _selectedBadges.remove(badge);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),
            _DetailSection(
              title: '연결된 원본 제보 ${widget.group.reports.length}건',
              child: Column(
                children: widget.group.reports.map((report) {
                  return _OriginalReportTile(report: report.report);
                }).toList(),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _busy
                        ? null
                        : () => _updateGroup(ApprovalStatus.needsRevision),
                    child: const Text('보완 요청'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _busy
                        ? null
                        : () => _updateGroup(ApprovalStatus.rejected),
                    child: const Text('반려'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: _busy
                        ? null
                        : () => _updateGroup(ApprovalStatus.approved),
                    child: Text(_busy ? '처리 중' : '그룹 승인'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.frame),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _AdminField extends StatelessWidget {
  const _AdminField({
    required this.label,
    required this.controller,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _OriginalReportTile extends StatelessWidget {
  const _OriginalReportTile({required this.report});

  final Report report;

  @override
  Widget build(BuildContext context) {
    final sourceMemo = report.inputItems.isEmpty
        ? null
        : report.inputItems.first['sourceMemo'] as String?;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.frame),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _iconForType(report.type),
                    color: AppColors.primaryGreen,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${report.type.label} · ${report.reporterNickname ?? '제보자'}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  Text(
                    _dateText(report.createdAt),
                    style: const TextStyle(
                      color: AppColors.textGray,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                report.description?.isNotEmpty == true
                    ? report.description!
                    : sourceMemo?.isNotEmpty == true
                    ? sourceMemo!
                    : '추가 설명 없음',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.textGray),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final color = score >= 70
        ? AppColors.primaryGreen
        : score >= 45
        ? AppColors.accentOrange
        : AppColors.danger;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Text(
          '$score점',
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.text});

  final IconData icon;
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.textGray),
            const SizedBox(width: 4),
            Text(
              text,
              style: const TextStyle(
                color: AppColors.textGray,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RiskChip extends StatelessWidget {
  const _RiskChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFEFEA),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFFFC8B8)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFFE0522D),
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _EmptyBucketState extends StatelessWidget {
  const _EmptyBucketState({required this.bucket});

  final _ReviewBucket bucket;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          '${bucket.label} 후보가 없습니다.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textGray,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _EmptyReviewState extends StatelessWidget {
  const _EmptyReviewState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                color: AppColors.softGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fact_check_outlined,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              '검토할 제보가 없습니다.',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            const Text(
              '새 제보가 접수되면 자동 정리된 후보로 보여드릴게요.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textGray),
            ),
          ],
        ),
      ),
    );
  }
}

List<_CandidateGroup> _buildCandidateGroups(List<Report> reports) {
  final map = <String, List<_ScoredReport>>{};

  for (final report in reports) {
    final scored = _scoreReport(report);
    final key = _groupKey(report);
    map.putIfAbsent(key, () => []).add(scored);
  }

  final groups =
      map.entries.map((entry) {
        return _CandidateGroup.fromReports(entry.key, entry.value);
      }).toList()..sort((a, b) {
        final bucketCompare = a.bucket.priority.compareTo(b.bucket.priority);
        if (bucketCompare != 0) return bucketCompare;
        final scoreCompare = b.score.compareTo(a.score);
        if (scoreCompare != 0) return scoreCompare;
        return b.latestAt.compareTo(a.latestAt);
      });

  return groups;
}

_ScoredReport _scoreReport(Report report) {
  var score = 0;
  final flags = <String>[];
  final text = [
    report.martName,
    report.title,
    report.description,
    ...report.inputItems.map((item) => item.values.join(' ')),
  ].whereType<String>().join(' ');
  final normalized = text.toLowerCase();
  final price = _extractPrice(text);

  if ((report.martName ?? '').trim().length >= 2) {
    score += 15;
  } else {
    flags.add('마트명 부족');
  }

  if ((report.title ?? '').trim().length >= 2) {
    score += 22;
  } else {
    flags.add('상품명 부족');
  }

  if (price != null) {
    score += 18;
  } else {
    flags.add('가격 정보 없음');
  }

  if ((report.description ?? '').trim().length >= 8) {
    score += 8;
  }

  if (report.imageUrls.isNotEmpty || normalized.contains('http')) {
    score += 14;
  } else {
    flags.add('사진 확인 필요');
  }

  if (report.type == ReportType.priceTag || report.type == ReportType.receipt) {
    score += 10;
  } else if (report.type == ReportType.flyer || report.type == ReportType.sms) {
    score += 8;
  }

  if ((report.reporterNickname ?? '').trim().isNotEmpty) score += 4;

  if (_hasSuspiciousText(normalized)) {
    score -= 30;
    flags.add('장난 의심 문구');
  }

  if (_hasRepeatedCharacters(normalized)) {
    score -= 12;
    flags.add('반복 문자');
  }

  return _ScoredReport(
    report: report,
    score: score.clamp(0, 100),
    riskFlags: flags,
    extractedPrice: price,
  );
}

String _groupKey(Report report) {
  final mart = _normalizeText(report.martName ?? 'unknown_mart');
  final product = _productKey(report.title ?? report.description ?? 'unknown');
  final price = _extractPrice(
    '${report.title ?? ''} ${report.description ?? ''}',
  );
  final priceBand = price == null ? 'no_price' : (price ~/ 100).toString();
  return '$mart::$product::$priceBand';
}

String _productKey(String value) {
  final normalized = _normalizeText(value);
  if (normalized.length <= 8) return normalized;
  return normalized.substring(0, 8);
}

String _normalizeText(String value) {
  return value
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), '')
      .replaceAll(RegExp(r'[^\uAC00-\uD7A3a-z0-9]'), '');
}

int? _extractPrice(String value) {
  final matches = RegExp(r'(\d{1,3}(?:,\d{3})+|\d{3,7})').allMatches(value);
  for (final match in matches) {
    final number = int.tryParse(match.group(0)!.replaceAll(',', ''));
    if (number != null && number >= 100) return number;
  }
  return null;
}

bool _hasSuspiciousText(String value) {
  const suspiciousWords = ['test', '테스트', '장난', 'ㅋㅋ', 'ㅎㅎ', 'asdf', '몰라'];
  return suspiciousWords.any(value.contains);
}

bool _hasRepeatedCharacters(String value) {
  return RegExp(r'(.)\1{4,}').hasMatch(value);
}

IconData _iconForType(ReportType type) {
  return switch (type) {
    ReportType.flyer => Icons.newspaper,
    ReportType.sms => Icons.sms_outlined,
    ReportType.receipt => Icons.receipt_long,
    ReportType.priceTag => Icons.local_offer_outlined,
    ReportType.manual => Icons.edit_note,
  };
}

String _dateText(DateTime date) {
  return '${date.month}/${date.day} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

const _badgeOptions = [
  '관리자 승인',
  '전단지 확인',
  '문자 확인',
  '매장 사진 확인',
  '영수증 확인',
  '오늘 확인',
  '수량 한정',
  '재고 소진 가능',
];

enum _ReviewBucket {
  recommended('승인 추천', 0),
  general('일반 검토', 1),
  duplicate('중복 의심', 2),
  infoMissing('정보 부족', 3),
  autoHold('자동 보류', 4),
  approved('승인 완료', 5);

  const _ReviewBucket(this.label, this.priority);

  final String label;
  final int priority;
}

class _ScoredReport {
  const _ScoredReport({
    required this.report,
    required this.score,
    required this.riskFlags,
    required this.extractedPrice,
  });

  final Report report;
  final int score;
  final List<String> riskFlags;
  final int? extractedPrice;
}

class _CandidateGroup {
  _CandidateGroup({
    required this.id,
    required this.reports,
    required this.score,
    required this.riskFlags,
    required this.bucket,
    required this.latestAt,
    required this.sourceSummary,
  });

  factory _CandidateGroup.fromReports(String id, List<_ScoredReport> reports) {
    final sorted = reports.toList()..sort((a, b) => b.score.compareTo(a.score));
    final score =
        (sorted.map((item) => item.score).fold<int>(0, (a, b) => a + b) /
                sorted.length)
            .round();
    final groupedRiskFlags = sorted
        .expand((item) => item.riskFlags)
        .toSet()
        .toList();
    final latestAt = sorted
        .map((item) => item.report.createdAt)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    final bucket = _resolveBucket(sorted, score, groupedRiskFlags);

    return _CandidateGroup(
      id: id,
      reports: sorted,
      score: _groupScore(score, sorted.length, sorted),
      riskFlags: groupedRiskFlags,
      bucket: bucket,
      latestAt: latestAt,
      sourceSummary: _sourceSummary(sorted.map((item) => item.report).toList()),
    );
  }

  final String id;
  final List<_ScoredReport> reports;
  final int score;
  final List<String> riskFlags;
  final _ReviewBucket bucket;
  final DateTime latestAt;
  final List<_SourceSummary> sourceSummary;

  Report get primaryReport => reports.first.report;

  String get martName {
    return primaryReport.martName?.isNotEmpty == true
        ? primaryReport.martName!
        : '마트명 확인 필요';
  }

  String get productTitle {
    return primaryReport.title?.isNotEmpty == true
        ? primaryReport.title!
        : '상품명 확인 필요';
  }

  String get priceText {
    final price = reports.first.extractedPrice;
    if (price == null) return '가격 확인 필요';
    return '₩${price.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')}';
  }

  int get reporterCount {
    return reports.map((item) => item.report.reporterId).toSet().length;
  }

  _GroupTone get tone {
    return switch (bucket) {
      _ReviewBucket.recommended => const _GroupTone(
        icon: Icons.verified_outlined,
        background: AppColors.softGreen,
        foreground: AppColors.primaryGreen,
      ),
      _ReviewBucket.general => const _GroupTone(
        icon: Icons.fact_check_outlined,
        background: AppColors.surfaceMuted,
        foreground: AppColors.textGray,
      ),
      _ReviewBucket.duplicate => const _GroupTone(
        icon: Icons.merge_type,
        background: AppColors.surfaceMuted,
        foreground: Color(0xFF64748B),
      ),
      _ReviewBucket.infoMissing => const _GroupTone(
        icon: Icons.info_outline,
        background: AppColors.softOrange,
        foreground: AppColors.accentOrange,
      ),
      _ReviewBucket.autoHold => const _GroupTone(
        icon: Icons.report_gmailerrorred,
        background: Color(0xFFFFEFEA),
        foreground: Color(0xFFE0522D),
      ),
      _ReviewBucket.approved => const _GroupTone(
        icon: Icons.check_circle_outline,
        background: AppColors.softGreen,
        foreground: AppColors.primaryGreen,
      ),
    };
  }

  String get recommendReason {
    if (bucket == _ReviewBucket.approved) return '이미 승인된 후보입니다.';
    if (bucket == _ReviewBucket.recommended) {
      return '마트명/상품명/가격 정보가 비교적 명확해 승인 우선 검토가 가능합니다.';
    }
    if (bucket == _ReviewBucket.duplicate) {
      return '같은 상품으로 보이는 제보가 묶여 있어 기존 특가 매칭 여부 확인이 필요합니다.';
    }
    if (bucket == _ReviewBucket.infoMissing) {
      return '상품명, 가격, 사진 중 일부가 부족해 보완 또는 수동 확인이 필요합니다.';
    }
    if (bucket == _ReviewBucket.autoHold) {
      return '장난/부실 가능성이 있어 우선순위를 낮춰 자동 보류했습니다.';
    }
    return '기본 정보는 있으나 최종 확인이 필요합니다.';
  }

  Set<String> get suggestedBadges {
    final badges = <String>{};
    for (final item in reports) {
      switch (item.report.type) {
        case ReportType.flyer:
          badges.add('전단지 확인');
        case ReportType.sms:
          badges.add('문자 확인');
        case ReportType.receipt:
          badges.add('영수증 확인');
        case ReportType.priceTag:
          badges.add('매장 사진 확인');
        case ReportType.manual:
          break;
      }
    }
    if (reports.length > 1) badges.add('${reports.length}건 확인');
    return badges;
  }
}

class _SourceSummary {
  const _SourceSummary({required this.icon, required this.text});

  final IconData icon;
  final String text;
}

class _GroupTone {
  const _GroupTone({
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
}

int _groupScore(
  int averageScore,
  int reportCount,
  List<_ScoredReport> reports,
) {
  final diversityBonus =
      reports.map((item) => item.report.type).toSet().length * 4;
  final countBonus = (reportCount - 1) * 8;
  return (averageScore + diversityBonus + countBonus).clamp(0, 100);
}

_ReviewBucket _resolveBucket(
  List<_ScoredReport> reports,
  int averageScore,
  List<String> riskFlags,
) {
  if (reports.every(
    (item) => item.report.approvalStatus == ApprovalStatus.approved,
  )) {
    return _ReviewBucket.approved;
  }
  if (riskFlags.contains('장난 의심 문구') || averageScore < 25) {
    return _ReviewBucket.autoHold;
  }
  if (averageScore >= 68 || (reports.length >= 2 && averageScore >= 55)) {
    return _ReviewBucket.recommended;
  }
  if (reports.length >= 2) return _ReviewBucket.duplicate;
  if (riskFlags.contains('상품명 부족') ||
      riskFlags.contains('가격 정보 없음') ||
      riskFlags.contains('마트명 부족')) {
    return _ReviewBucket.infoMissing;
  }
  return _ReviewBucket.general;
}

List<_SourceSummary> _sourceSummary(List<Report> reports) {
  final counts = <ReportType, int>{};
  for (final report in reports) {
    counts[report.type] = (counts[report.type] ?? 0) + 1;
  }
  return counts.entries.map((entry) {
    return _SourceSummary(
      icon: _iconForType(entry.key),
      text: '${entry.key.label} ${entry.value}',
    );
  }).toList();
}
