import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/app_enums.dart';
import '../../models/report.dart';
import '../firestore_collections.dart';

class ReportRepository {
  ReportRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreCollections.reports);

  Stream<List<Report>> watchMyReports(String reporterId) {
    return _collection
        .where('reporterId', isEqualTo: reporterId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Report.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<Report>> watchPendingReports() {
    return _collection
        .where('approvalStatus', isEqualTo: ApprovalStatus.pending.name)
        .orderBy('createdAt')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Report.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<Report>> watchAdminReports({int limit = 100}) {
    return _collection
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Report.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<DocumentReference<Map<String, dynamic>>> createReport(Report report) {
    return _collection.add(report.toMap());
  }

  Future<void> updateStatus({
    required String reportId,
    required ApprovalStatus status,
    String? adminMemo,
    int? rewardPoint,
  }) {
    return _collection.doc(reportId).update({
      'approvalStatus': status.name,
      'adminMemo': adminMemo,
      'rewardPoint': rewardPoint,
      'reviewedAt': FieldValue.serverTimestamp(),
    });
  }
}
