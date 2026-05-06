import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/app_enums.dart';
import '../../models/mart_review.dart';
import '../firestore_collections.dart';

class ReviewRepository {
  ReviewRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreCollections.reviews);

  Future<DocumentReference<Map<String, dynamic>>> createReview(
    MartReview review,
  ) {
    return _collection.add(review.toMap());
  }

  Stream<List<MartReview>> watchPublishedReviews({
    required String targetName,
    required ReviewTargetType targetType,
  }) {
    return _collection
        .where('targetType', isEqualTo: targetType.name)
        .where('targetName', isEqualTo: targetName)
        .where('status', isEqualTo: ReviewStatus.published.name)
        .orderBy('publishedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MartReview.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> updateStatus({
    required String reviewId,
    required ReviewStatus status,
    String? adminMemo,
  }) {
    return _collection.doc(reviewId).update({
      'status': status.name,
      'adminMemo': adminMemo,
      'publishedAt': status == ReviewStatus.published
          ? FieldValue.serverTimestamp()
          : null,
    });
  }
}
