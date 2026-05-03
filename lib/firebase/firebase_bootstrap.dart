import 'package:firebase_core/firebase_core.dart';

enum FirebaseBootstrapStatus {
  ready,
  missingConfiguration,
}

class FirebaseBootstrap {
  static Future<FirebaseBootstrapStatus> initialize() async {
    try {
      await Firebase.initializeApp();
      return FirebaseBootstrapStatus.ready;
    } on Object {
      return FirebaseBootstrapStatus.missingConfiguration;
    }
  }
}
