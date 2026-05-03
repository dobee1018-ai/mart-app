import 'app_enums.dart';
import '../data/firestore_date.dart';

class PointTransaction {
  const PointTransaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.relatedReportId,
    this.processedAt,
  });

  final String id;
  final String userId;
  final String type;
  final int amount;
  final PointStatus status;
  final DateTime createdAt;
  final String? relatedReportId;
  final DateTime? processedAt;

  factory PointTransaction.fromMap(String id, Map<String, dynamic> data) {
    return PointTransaction(
      id: id,
      userId: data['userId'] as String? ?? '',
      type: data['type'] as String? ?? '',
      amount: data['amount'] as int? ?? 0,
      status: PointStatus.values.byName(data['status'] as String? ?? 'scheduled'),
      createdAt: dateTimeFromFirestore(data['createdAt']) ?? DateTime.now(),
      relatedReportId: data['relatedReportId'] as String?,
      processedAt: dateTimeFromFirestore(data['processedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type,
      'amount': amount,
      'status': status.name,
      'createdAt': dateTimeToFirestore(createdAt),
      'relatedReportId': relatedReportId,
      'processedAt': dateTimeToFirestore(processedAt),
    };
  }
}
