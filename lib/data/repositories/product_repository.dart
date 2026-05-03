import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/product.dart';
import '../firestore_collections.dart';

class ProductRepository {
  ProductRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreCollections.products);

  Stream<List<Product>> watchProducts() {
    return _collection.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Product.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<Product>> searchProducts(String query) {
    final normalized = query.trim();
    if (normalized.isEmpty) return watchProducts();

    return _collection
        .where('keywords', arrayContains: normalized)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Product.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> upsertProduct(Product product) {
    return _collection
        .doc(product.id)
        .set(product.toMap(), SetOptions(merge: true));
  }
}
