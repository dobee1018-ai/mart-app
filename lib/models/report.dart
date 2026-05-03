import 'app_enums.dart';
import '../data/firestore_date.dart';

class Report {
  const Report({
    required this.id,
    required this.reporterId,
    required this.type,
    required this.approvalStatus,
    required this.createdAt,
    this.martId,
    this.martName,
    this.imageUrls = const [],
    this.inputItems = const [],
    this.ocrResult,
    this.adminMemo,
    this.rewardPoint = 0,
    this.reviewedAt,
  });

  final String id;
  final String reporterId;
  final ReportType type;
  final ApprovalStatus approvalStatus;
  final DateTime createdAt;
  final String? martId;
  final String? martName;
  final List<String> imageUrls;
  final List<Map<String, dynamic>> inputItems;
  final Map<String, dynamic>? ocrResult;
  final String? adminMemo;
  final int rewardPoint;
  final DateTime? reviewedAt;

  factory Report.fromMap(String id, Map<String, dynamic> data) {
    return Report(
      id: id,
      reporterId: data['reporterId'] as String? ?? '',
      type: ReportType.values.byName(data['type'] as String? ?? 'manual'),
      approvalStatus: ApprovalStatus.values.byName(
        data['approvalStatus'] as String? ?? 'pending',
      ),
      createdAt: dateTimeFromFirestore(data['createdAt']) ?? DateTime.now(),
      martId: data['martId'] as String?,
      martName: data['martName'] as String?,
      imageUrls: List<String>.from(data['imageUrls'] as List? ?? const []),
      inputItems: List<Map<String, dynamic>>.from(
        data['inputItems'] as List? ?? const [],
      ),
      ocrResult: data['ocrResult'] as Map<String, dynamic>?,
      adminMemo: data['adminMemo'] as String?,
      rewardPoint: data['rewardPoint'] as int? ?? 0,
      reviewedAt: dateTimeFromFirestore(data['reviewedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reporterId': reporterId,
      'type': type.name,
      'approvalStatus': approvalStatus.name,
      'createdAt': dateTimeToFirestore(createdAt),
      'martId': martId,
      'martName': martName,
      'imageUrls': imageUrls,
      'inputItems': inputItems,
      'ocrResult': ocrResult,
      'adminMemo': adminMemo,
      'rewardPoint': rewardPoint,
      'reviewedAt': dateTimeToFirestore(reviewedAt),
    };
  }
}
