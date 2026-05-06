enum ReviewModerationStatus { scheduled, needsReview, blocked }

class ReviewModerationResult {
  const ReviewModerationResult({
    required this.status,
    required this.message,
    required this.flags,
    required this.publishAfter,
  });

  final ReviewModerationStatus status;
  final String message;
  final List<String> flags;
  final Duration publishAfter;

  bool get canSubmit => status != ReviewModerationStatus.blocked;
}

class ReviewModeration {
  const ReviewModeration._();

  static const defaultPublishDelay = Duration(hours: 24);

  static final List<RegExp> _blockedPatterns = [
    RegExp(r'시\s*발|씨\s*발|ㅅ\s*ㅂ', caseSensitive: false),
    RegExp(r'병\s*신|ㅂ\s*ㅅ', caseSensitive: false),
    RegExp(r'개\s*새|개\s*색|새\s*끼', caseSensitive: false),
    RegExp(r'좆|ㅈ\s*같|꺼\s*져', caseSensitive: false),
    RegExp(r'죽\s*어|망\s*해\s*라', caseSensitive: false),
    RegExp(r'무료\s*대출|바카라|토토|카지노|성인\s*광고', caseSensitive: false),
  ];

  static final List<RegExp> _reviewRequiredPatterns = [
    RegExp(r'https?://|www\.', caseSensitive: false),
    RegExp(r'\d{2,3}-\d{3,4}-\d{4}'),
    RegExp(r'카톡|오픈채팅|텔레그램|입금|계좌', caseSensitive: false),
    RegExp(r'최악|사기|불매|고소|신고', caseSensitive: false),
  ];

  static ReviewModerationResult check(String rawText) {
    final text = rawText.trim();
    final normalized = text.replaceAll(RegExp(r'\s+'), '').toLowerCase();
    final flags = <String>[];

    if (text.length < 10) {
      return const ReviewModerationResult(
        status: ReviewModerationStatus.blocked,
        message: '리뷰 내용을 10자 이상으로 조금 더 자세히 작성해주세요.',
        flags: ['내용이 너무 짧음'],
        publishAfter: Duration.zero,
      );
    }

    if (_hasRepeatedCharacters(normalized)) {
      flags.add('반복 문자 과다');
    }

    if (_blockedPatterns.any((pattern) => pattern.hasMatch(normalized))) {
      return ReviewModerationResult(
        status: ReviewModerationStatus.blocked,
        message: '부적절한 표현이 포함되어 있어 등록할 수 없어요. 표현을 수정해주세요.',
        flags: [...flags, '금칙어 포함'],
        publishAfter: Duration.zero,
      );
    }

    final reviewFlags = _reviewRequiredPatterns
        .where((pattern) => pattern.hasMatch(text))
        .map((pattern) => _flagLabel(pattern.pattern))
        .toList();
    flags.addAll(reviewFlags);

    if (flags.isNotEmpty) {
      return ReviewModerationResult(
        status: ReviewModerationStatus.needsReview,
        message: '검토가 필요한 표현이 있어 관리자 확인 후 공개됩니다.',
        flags: flags,
        publishAfter: defaultPublishDelay,
      );
    }

    return const ReviewModerationResult(
      status: ReviewModerationStatus.scheduled,
      message: '리뷰가 접수되었어요. 24시간 검토 대기 후 공개 예정입니다.',
      flags: [],
      publishAfter: defaultPublishDelay,
    );
  }

  static bool _hasRepeatedCharacters(String value) {
    return RegExp(r'(.)\1{4,}').hasMatch(value);
  }

  static String _flagLabel(String pattern) {
    if (pattern.contains('http')) return '외부 링크 포함';
    if (pattern.contains(r'\d')) return '연락처 형식 포함';
    if (pattern.contains('카톡')) return '외부 연락 유도';
    return '강한 부정 표현';
  }
}
