## Release Guide

This guide covers creating production builds with and without Shorebird for iOS and Android.

### Prerequisites

- Ensure Flutter and Dart are up to date: `flutter --version`
- Verify toolchain: `flutter doctor -v`
- Set app version in `pubspec.yaml` (`version: x.y.z+build`)
- Fetch deps: `flutter clean && flutter pub get`
- iOS: Xcode, CocoaPods installed; Android: Android SDK + NDK per project

### Common Notes

- Optional: pick device for `flutter run --release` using `-d <device-id>`
- For CI builds, prefer deterministic env: `--no-tree-shake-icons` as needed
- Use `--release` for run, and `build` commands below for artifacts

---

## Standard Flutter (no Shorebird)

### iOS

Build IPA (requires signing configured in Xcode project):

```bash
flutter build ipa --release
```

Result: `build/ios/ipa/*.ipa`

Run on a device/simulator in release (no artifact):

```bash
flutter run --release -d <device-id>
```

Archive via Xcode (optional):

1. `flutter build ios --release`
2. Open `ios/Runner.xcworkspace` → Product → Archive

### Android

Build App Bundle (Play Store recommended):

```bash
flutter build appbundle --release
```

Result: `build/app/outputs/bundle/release/app-release.aab`

Build APK (for sideload/testing):

```bash
flutter build apk --release
```

Result: `build/app/outputs/flutter-apk/app-release.apk`

Run on a device in release (no artifact):

```bash
flutter run --release -d <device-id>
```

---

## Shorebird Releases

Shorebird enables over-the-air (OTA) patching for Flutter.

Ensure Shorebird is installed and authenticated:

```bash
shorebird doctor
shorebird login
```

### iOS (Shorebird)

Create a Shorebird release (initial full release):

```bash
shorebird release ios --release
```

Notes:

- Configure signing in Xcode before uploading to App Store Connect.
- Shorebird outputs instructions and artifact paths upon completion.

Create a patch for an existing iOS release:

```bash
shorebird patch ios
```

### Android (Shorebird)

Create a Shorebird release (AAB):

```bash
shorebird release android --release
```

Optional track specification (if supported by your setup):

```bash
shorebird release android --release --track production
```

Create a patch for an existing Android release:

```bash
shorebird patch android
```

---

## Signing & Credentials

- iOS: Use Xcode automatic signing or configure provisioning profiles and certificates. `flutter build ipa` reads signing from the Xcode project.
- Android: Ensure `android/key.properties` and signingConfigs are set in `android/app/build.gradle` for release builds.

---

## Versioning & Changelog

1. Update `pubspec.yaml` version (e.g., `1.0.0+21`).
2. Tag in git (optional): `git tag v1.0.0+21 && git push --tags`.
3. Update store listing changelogs (Play Console / App Store Connect).

---

## Quick Commands Cheat Sheet

```bash
# iOS
flutter build ipa --release
shorebird release ios 
shorebird patch ios

# Android
flutter build appbundle --release
flutter build apk --release
shorebird release android 
shorebird patch android

# Run in release on a specific device
flutter run --release -d <device-id>
```
