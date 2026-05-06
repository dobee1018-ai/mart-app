import '../data/firestore_date.dart';
import 'app_enums.dart';

class MartReview {
  const MartReview({
    required this.id,
    required this.userId,
    required this.userNickname,
    required this.targetType,
    required this.targetName,
    required this.rating,
    required this.content,
    required this.status,
    required this.createdAt,
    required this.publishAt,
    this.moderationFlags = const [],
    this.adminMemo,
    this.publishedAt,
  });

  final String id;
  final String userId;
  final String userNickname;
  final ReviewTargetType targetType;
  final String targetName;
  final int rating;
  final String content;
  final ReviewStatus status;
  final DateTime createdAt;
  final DateTime publishAt;
  final List<String> moderationFlags;
  final String? adminMemo;
  final DateTime? publishedAt;

  factory MartReview.fromMap(String id, Map<String, dynamic> data) {
    return MartReview(
      id: id,
      userId: data['userId'] as String? ?? '',
      userNickname: data['userNickname'] as String? ?? '동네마트 회원',
      targetType: ReviewTargetType.values.byName(
        data['targetType'] as String? ?? ReviewTargetType.mart.name,
      ),
      targetName: data['targetName'] as String? ?? '',
      rating: data['rating'] as int? ?? 0,
      content: data['content'] as String? ?? '',
      status: ReviewStatus.values.byName(
        data['status'] as String? ?? ReviewStatus.scheduled.name,
      ),
      createdAt: dateTimeFromFirestore(data['createdAt']) ?? DateTime.now(),
      publishAt: dateTimeFromFirestore(data['publishAt']) ?? DateTime.now(),
      moderationFlags: List<String>.from(
        data['moderationFlags'] as List? ?? const [],
      ),
      adminMemo: data['adminMemo'] as String?,
      publishedAt: dateTimeFromFirestore(data['publishedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userNickname': userNickname,
      'targetType': targetType.name,
      'targetName': targetName,
      'rating': rating,
      'content': content,
      'status': status.name,
      'createdAt': dateTimeToFirestore(createdAt),
      'publishAt': dateTimeToFirestore(publishAt),
      'moderationFlags': moderationFlags,
      'adminMemo': adminMemo,
      'publishedAt': dateTimeToFirestore(publishedAt),
    };
  }
}
