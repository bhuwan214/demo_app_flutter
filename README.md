# demo_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Firebase + Google Sign-In

1. Install the FlutterFire CLI (`dart pub global activate flutterfire_cli`) and run `flutterfire configure` inside the project to regenerate `lib/firebase_options.dart` whenever you add more Firebase apps (iOS, web, desktop) or rotate API keys.
2. Android already contains `android/app/google-services.json` and applies the `com.google.gms.google-services` plugin. If you change the package name or SHA-1, download an updated JSON from the Firebase console and replace the existing file.
3. For iOS, download `GoogleService-Info.plist` from Firebase and add it to `ios/Runner`. Then rerun `flutterfire configure` so iOS options are emitted; Xcode also needs the Firebase CocoaPods (`pod install`).
4. The app calls `Firebase.initializeApp` at startup and uses `firebase_auth` + `google_sign_in` to obtain a Google identity, then it exchanges the profile with your backend (`/api/v2/ecommerce/customer/google/login`) to receive the API token saved via `AuthService`.
5. To test locally: `flutter run --flavor development` (or just `flutter run`). On first login, pick the Google account, approve the consent screen, and confirm that you are navigated to `/home`. Use `flutter logs` to inspect Firebase/HTTP output if something goes wrong.
