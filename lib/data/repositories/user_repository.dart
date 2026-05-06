import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/app_enums.dart';
import '../firestore_collections.dart';

class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> saveSignedInUser(User user) async {
    final doc = _firestore.collection(FirestoreCollections.users).doc(user.uid);
    final snapshot = await doc.get();
    final data = {
      'displayName': user.displayName,
      'email': user.email,
      'photoURL': user.photoURL,
      'providerIds': user.providerData
          .map((provider) => provider.providerId)
          .toList(),
      'region': '원주시',
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (!snapshot.exists) {
      data['role'] = UserRole.user.name;
      data['createdAt'] = FieldValue.serverTimestamp();
    }

    return doc.set(data, SetOptions(merge: true));
  }

  Stream<UserRole> watchUserRole(String uid) {
    return _firestore
        .collection(FirestoreCollections.users)
        .doc(uid)
        .snapshots()
        .map((snapshot) {
          final roleName = snapshot.data()?['role'] as String? ?? 'user';
          return UserRole.values.firstWhere(
            (role) => role.name == roleName,
            orElse: () => UserRole.user,
          );
        });
  }
}
