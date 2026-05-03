import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/app_enums.dart';
import '../../models/price_item.dart';
import '../firestore_collections.dart';

class PriceItemRepository {
  PriceItemRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreCollections.priceItems);

  Stream<List<PriceItem>> watchApprovedByProduct(String productId) {
    return _collection
        .where('productId', isEqualTo: productId)
        .where('approvalStatus', isEqualTo: ApprovalStatus.approved.name)
        .orderBy('salePrice')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PriceItem.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<PriceItem>> watchApprovedByMart(String martId) {
    return _collection
        .where('martId', isEqualTo: martId)
        .where('approvalStatus', isEqualTo: ApprovalStatus.approved.name)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PriceItem.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<PriceItem>> watchTopDeals({int limit = 20}) {
    return _collection
        .where('approvalStatus', isEqualTo: ApprovalStatus.approved.name)
        .orderBy('discountRate', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PriceItem.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> upsertPriceItem(PriceItem item) {
    return _collection.doc(item.id).set(item.toMap(), SetOptions(merge: true));
  }
}
