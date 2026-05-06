import 'package:firebase_core/firebase_core.dart';

import '../firebase_options.dart';

enum FirebaseBootstrapStatus { ready, missingConfiguration }

class FirebaseBootstrap {
  static Future<FirebaseBootstrapStatus> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      return FirebaseBootstrapStatus.ready;
    } on Object {
      return FirebaseBootstrapStatus.missingConfiguration;
    }
  }
}
