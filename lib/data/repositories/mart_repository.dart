import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/app_enums.dart';
import '../../models/mart.dart';
import '../firestore_collections.dart';

class MartRepository {
  MartRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreCollections.marts);

  Stream<List<Mart>> watchVisibleMarts() {
    return _collection
        .where('status', isEqualTo: MartStatus.open.name)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Mart.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<Mart?> getMart(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return Mart.fromMap(doc.id, doc.data()!);
  }

  Future<void> upsertMart(Mart mart) {
    return _collection.doc(mart.id).set(mart.toMap(), SetOptions(merge: true));
  }
}
