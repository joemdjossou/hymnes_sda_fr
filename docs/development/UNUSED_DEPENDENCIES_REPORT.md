# Unused Dependencies Analysis Report

## Summary
After analyzing the codebase, here are the dependencies that can potentially be removed or moved:

## ⚠️ Potentially Unused Dependencies

### 1. `cupertino_icons: ^1.0.2`
- **Status**: ❌ No direct imports found in codebase
- **Usage**: Provides iOS-style icons for Cupertino widgets
- **Found**: No `CupertinoIcons` or `cupertino_icons` imports
- **Note**: `GlobalCupertinoLocalizations.delegate` is used, but this is part of Flutter's core localization and doesn't require the `cupertino_icons` package
- **Recommendation**: ✅ **SAFE TO REMOVE** - You're not using any Cupertino widgets that would need these icons

## ✅ Dependencies That Are Used (Keep These)

All other dependencies are actively used:

### Runtime Dependencies
- ✅ `sentry_flutter` - Error tracking (main.dart, error_logging_service.dart)
- ✅ `go_router` - Navigation
- ✅ `flutter_bloc` - State management
- ✅ `equatable` - Value equality
- ✅ `shared_preferences` - Settings storage
- ✅ `objectbox` & `objectbox_flutter_libs` - Local storage
- ✅ `gap` - Spacing widget
- ✅ `just_audio` - Audio playback
- ✅ `webview_flutter` - PDF display
- ✅ `http` - HTTP requests
- ✅ `url_launcher` - Opening URLs
- ✅ `share_plus` - Sharing functionality
- ✅ `firebase_auth` & `firebase_core` - Authentication
- ✅ `google_sign_in` & `sign_in_with_apple` - Sign in methods
- ✅ `logger` - Logging (used in 13+ files)
- ✅ `package_info_plus` - App version info
- ✅ `path_provider` - File system access
- ✅ `shimmer` - Loading effects (used in 11+ files)
- ✅ `cloud_firestore` - Cloud database
- ✅ `posthog_flutter` - Analytics
- ✅ `upgrader` - App update checker (HomeScreen - UpgradeAlert widget)
- ✅ `flutter_local_notifications` - Local notifications
- ✅ `permission_handler` - Permissions
- ✅ `timezone` - Timezone support
- ✅ `onesignal_flutter` - Push notifications (main.dart)
- ✅ `home_widget` - Home widget (used in 8+ files)
- ✅ `connectivity_plus` - Network connectivity (connectivity_service.dart)
- ✅ `flutter_native_splash` - Used at runtime (main.dart - FlutterNativeSplash.remove())

### Build Tools (Correctly Placed)
- ✅ `flutter_launcher_icons` - Build tool for generating app icons (configured in pubspec.yaml)
- ✅ `flutter_gen` - Build tool for generating asset access code (generates lib/gen/assets.gen.dart)

### Dev Dependencies (Correctly Placed)
- ✅ `sentry_dart_plugin` - Sentry build tool
- ✅ `flutter_lints` - Linting
- ✅ `objectbox_generator` - Code generation
- ✅ `build_runner` - Code generation
- ✅ `mockito` - Testing (used in test files)
- ✅ `bloc_test` - Testing (used in test files)
- ✅ `integration_test` - Testing

## 📋 Action Items

### Recommended Removal:
1. **Remove `cupertino_icons: ^1.0.2`** from dependencies
   ```yaml
   # Remove this line:
   cupertino_icons: ^1.0.2
   ```

### Optional: Move Build Tools to dev_dependencies
If you want to be more strict about dependency management, you could move these build tools to `dev_dependencies`:
- `flutter_launcher_icons` (but keep it if you need it at runtime)
- `flutter_native_splash` (currently used at runtime, so keep in dependencies)

However, `flutter_native_splash` is used at runtime (`FlutterNativeSplash.remove()`), so it should stay in `dependencies`.

## 🎯 Final Recommendation

**Only remove**: `cupertino_icons: ^1.0.2`

All other dependencies are either:
- Actively used in the codebase
- Build tools that generate code/assets
- Dev dependencies for testing
- Runtime dependencies that are called programmatically

