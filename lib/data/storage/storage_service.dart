import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  StorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  Future<String> uploadReportImage({
    required String userId,
    required String fileName,
    required Uint8List bytes,
    required String contentType,
  }) {
    return _uploadImage(
      path: 'reports/$userId/$fileName',
      bytes: bytes,
      contentType: contentType,
    );
  }

  Future<String> uploadReceiptImage({
    required String userId,
    required String fileName,
    required Uint8List bytes,
    required String contentType,
  }) {
    return _uploadImage(
      path: 'receipts/$userId/$fileName',
      bytes: bytes,
      contentType: contentType,
    );
  }

  Future<String> uploadFlyerImage({
    required String martId,
    required String fileName,
    required Uint8List bytes,
    required String contentType,
  }) {
    return _uploadImage(
      path: 'flyers/$martId/$fileName',
      bytes: bytes,
      contentType: contentType,
    );
  }

  Future<String> _uploadImage({
    required String path,
    required Uint8List bytes,
    required String contentType,
  }) async {
    final ref = _storage.ref(path);
    final metadata = SettableMetadata(contentType: contentType);
    await ref.putData(bytes, metadata);
    return ref.getDownloadURL();
  }
}
