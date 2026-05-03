import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/shopping_memo.dart';
import '../firestore_collections.dart';

class ShoppingMemoRepository {
  ShoppingMemoRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreCollections.shoppingMemos);

  Stream<List<ShoppingMemo>> watchMyMemos(String userId) {
    return _collection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ShoppingMemo.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> addMemo(ShoppingMemo memo) {
    return _collection.doc(memo.id).set(memo.toMap());
  }

  Future<void> setCompleted(String memoId, bool completed) {
    return _collection.doc(memoId).update({'completed': completed});
  }
}
