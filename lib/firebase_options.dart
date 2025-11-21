import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase configuration generated from android/app/google-services.json.
/// Run `flutterfire configure` to regenerate this file when you add more
/// platforms (iOS, web, desktop) or rotate keys.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Firebase options have not been configured for web. Run `flutterfire configure`.',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'Firebase options have not been configured for this platform. '
          'Add the platform in Firebase Console and rerun `flutterfire configure`.',
        );
      case TargetPlatform.fuchsia:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for Fuchsia.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAeEUzRx4NKduA6-Kzw7NCYbaRcBNQ00Zo',
    appId: '1:523220852214:android:f10a581cf0676106b37bd7',
    messagingSenderId: '523220852214',
    projectId: 'fir-houler',
    storageBucket: 'fir-houler.firebasestorage.app',
  );
}
