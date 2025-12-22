# Hymns Sync Implementation Plan

## Offline-First with Online Updates & Rollback Safety

---

## 📋 Overview

**Goal**: Enable silent, automatic updates to `hymns.json` without app store releases, with robust rollback capabilities.

**Strategy**: Firebase Realtime Database (metadata) + Firebase Storage (JSON file) + Local file versioning

**File Size**: 786 KB

**Update Type**: Silent, full file replacement

**Safety**: Dual-version storage (current + previous) with automatic rollback

---

## 🏗️ Architecture

### 1. Firebase Structure

#### Realtime Database (`/hymns_metadata/`)

```json
{
  "hymns_metadata": {
    "version": "2.1.0",
    "lastUpdated": 1700000000000,
    "downloadUrl": "https://firebasestorage.googleapis.com/.../hymns_v2.1.0.json",
    "fileSize": 803840,
    "hymnsCount": 850,
    "checksum": "a3f5e8d...",
    "minAppVersion": "1.0.0",
    "releaseNotes": "Added 15 new hymns"
  }
}
```

#### Firebase Storage

```
/hymns/
  ├── hymns_v2.1.0.json (current)
  ├── hymns_v2.0.9.json (previous, kept for rollback)
  └── hymns_v1.9.5.json (older versions)
```

---

### 2. Local Storage Structure

#### A. SharedPreferences (Metadata)

```dart
class HymnsVersionMetadata {
  // Current active version
  String currentVersion;           // "2.1.0"
  String currentVersionChecksum;   // "a3f5e8d..."
  int currentVersionTimestamp;     // When downloaded
  String currentVersionStatus;     // "stable" | "failed" | "testing"

  // Previous version (for rollback)
  String previousVersion;          // "2.0.9"
  String previousVersionChecksum;  // "b7c2d9f..."
  int previousVersionTimestamp;

  // Bundled version (from assets)
  String bundledVersion;           // "2.0.0"

  // Last check info
  int lastUpdateCheck;             // Timestamp
  bool autoUpdateEnabled;          // true
}
```

#### B. Local Files (using `path_provider`)

```
<app_documents>/hymns/
  ├── hymns_current.json     (Active version - loaded by app)
  ├── hymns_previous.json    (Backup - for rollback)
  └── hymns_temp.json        (Temporary download - validated before use)
```

#### C. Assets (Bundled)

```
assets/data/hymns.json       (Fallback for first install)
```

---

## 🔄 Implementation Flow

### Phase 1: Initial Setup (First App Launch)

```
1. Check if hymns_current.json exists
   NO → Copy from assets/hymns.json → hymns_current.json
   YES → Load from hymns_current.json

2. Initialize SharedPreferences metadata
   - currentVersion = bundledVersion (from assets)
   - previousVersion = null
   - currentVersionStatus = "stable"

3. Schedule background update check
```

---

### Phase 2: Background Update Check (Silent)

```
Trigger:
  - App launch (with delay)
  - Every 24 hours (background)
  - Manual refresh (optional settings)

Flow:
1. Check internet connectivity
   NO → Skip silently
   YES → Continue

2. Fetch metadata from Firebase Realtime Database
   GET: /hymns_metadata/

3. Compare versions
   Remote version <= Local current version → Skip
   Remote version > Local current version → Proceed to download

4. Pre-download validations
   ✓ Check minAppVersion compatibility
   ✓ Check available storage space (fileSize * 2)
   ✓ Verify download URL is valid

5. Download hymns file
   → Download to hymns_temp.json
   → Show silent progress (optional notification)

6. Post-download validations
   ✓ File size matches metadata.fileSize (±1%)
   ✓ Checksum matches metadata.checksum
   ✓ JSON is valid and parseable
   ✓ Required fields exist (validate structure)
   ✓ Hymns count matches metadata.hymnsCount (±5%)

   VALIDATION FAILED → Delete temp, keep current, log error
   VALIDATION PASSED → Continue to activation

7. Atomic file swap (CRITICAL for safety)
   a. Rename hymns_current.json → hymns_previous.json (backup)
   b. Rename hymns_temp.json → hymns_current.json (activate)
   c. Update SharedPreferences:
      - previousVersion = old currentVersion
      - currentVersion = new version
      - currentVersionStatus = "stable"
      - Update timestamps and checksums

8. Post-activation
   - Delete old hymns_previous.json (only keep 2 versions)
   - Log successful update to analytics
   - Optional: Show subtle toast notification
```

---

### Phase 3: Rollback Mechanism

```
Trigger:
  - hymns_current.json fails to load
  - JSON parsing error
  - Missing critical data
  - App crash during hymn loading

Automatic Rollback Flow:
1. Detect failure during hymn loading
2. Check if hymns_previous.json exists
   YES → Restore previous version
   NO → Fall back to assets/hymns.json

3. Restore Process:
   a. Copy hymns_previous.json → hymns_current.json
   b. Update SharedPreferences:
      - currentVersion = previousVersion
      - currentVersionStatus = "failed" (mark bad version)
      - Add failed version to blacklist

4. Blacklist failed version
   - Store failedVersions list in SharedPreferences
   - Skip this version in future update checks

5. Report error to Sentry
   - Version that failed
   - Error details
   - Rollback success/failure

6. Notify user (subtle)
   "Using previous hymn version due to technical issue"
```

---

### Phase 4: Manual Recovery Options

Add to Settings Screen:

```dart
// Settings → Advanced → Hymns Data
- Current Version: 2.1.0
- Previous Version: 2.0.9 (Backup)
- Last Updated: 2 hours ago

Actions:
[Check for Updates]        // Force check now
[Revert to Previous]       // Manual rollback
[Reset to Original]        // Restore from assets
[Clear Downloaded Data]    // Force re-download
```

---

## 🛡️ Safety Mechanisms

### 1. Validation Layers

```dart
class HymnsValidator {
  // Level 1: File integrity
  static bool validateFileIntegrity(File file, int expectedSize, String checksum);

  // Level 2: JSON structure
  static bool validateJsonStructure(Map<String, dynamic> json);

  // Level 3: Required fields
  static bool validateRequiredFields(Map<String, dynamic> hymn);

  // Level 4: Data consistency
  static bool validateHymnsCount(List hymns, int expectedCount);

  // Level 5: Business logic
  static bool validateHymnNumbers(List hymns); // No duplicates, proper sequence
}
```

### 2. Atomic Operations

```dart
class AtomicFileOperations {
  // Always write to temp first, then atomic move
  static Future<bool> safeFileSwap({
    required File current,
    required File backup,
    required File newFile,
  }) async {
    try {
      // 1. Create backup
      if (await current.exists()) {
        await current.copy(backup.path);
      }

      // 2. Move new file to current (atomic)
      await newFile.rename(current.path);

      return true;
    } catch (e) {
      // Restore from backup if swap failed
      if (await backup.exists()) {
        await backup.copy(current.path);
      }
      return false;
    }
  }
}
```

### 3. Error Recovery States

```dart
enum HymnsLoadState {
  loadingFromCurrent,    // Try current version
  loadingFromPrevious,   // Rollback to previous
  loadingFromAssets,     // Ultimate fallback
  loadingFailed,         // All sources failed
}
```

### 4. Network Resilience

```dart
class NetworkAwareSync {
  // Only sync on WiFi (optional setting)
  bool syncOnlyOnWifi = true;

  // Retry logic with exponential backoff
  int maxRetries = 3;
  Duration initialDelay = Duration(seconds: 5);

  // Timeout handling
  Duration downloadTimeout = Duration(minutes: 2);
}
```

---

## 📝 Implementation Files

### New Files to Create

1. **`lib/core/services/hymns_sync_service.dart`**

   - Version checking
   - Download management
   - Validation orchestration
   - Update notifications

2. **`lib/core/services/hymns_storage_service.dart`**

   - Local file management
   - Atomic file operations
   - Version metadata handling

3. **`lib/core/services/hymns_validator.dart`**

   - Multi-layer validation
   - Checksum verification
   - Structure validation

4. **`lib/core/models/hymns_version_metadata.dart`**

   - Version metadata model
   - Serialization/deserialization

5. **`lib/core/repositories/hymns_repository.dart`** (Update existing)
   - Abstract hymn loading logic
   - Source priority: current → previous → assets
   - Automatic rollback on failure

---

## 🔧 Firebase Setup Steps

### Step 1: Realtime Database Rules

```json
{
  "rules": {
    "hymns_metadata": {
      ".read": true,
      ".write": false // Only you can write (via Firebase Console or Admin SDK)
    }
  }
}
```

### Step 2: Storage Rules

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /hymns/{fileName} {
      allow read: if true;
      allow write: if false;  // Only you can upload
    }
  }
}
```

### Step 3: Initial Data Upload

```bash
# 1. Upload hymns.json to Storage
# 2. Get download URL
# 3. Create metadata in Realtime Database
```

---

## 🎯 Implementation Phases

### Phase 1: Foundation (Day 1-2)

- [ ] Create file structure and models
- [ ] Implement `HymnsStorageService` (local file management)
- [ ] Implement `HymnsValidator` (validation logic)
- [ ] Add unit tests for validators

### Phase 2: Sync Logic (Day 3-4)

- [ ] Implement `HymnsSyncService`
- [ ] Version comparison logic
- [ ] Download with progress
- [ ] Integration with Firebase

### Phase 3: Safety & Rollback (Day 5-6)

- [ ] Implement atomic file swaps
- [ ] Rollback mechanism
- [ ] Error recovery states
- [ ] Version blacklisting

### Phase 4: Integration (Day 7-8)

- [ ] Update `HymnsRepository` to use new storage
- [ ] Update `HymnDataService` integration
- [ ] Background sync scheduling
- [ ] Settings UI for manual controls

### Phase 5: Testing (Day 9-10)

- [ ] Unit tests (validators, file ops)
- [ ] Integration tests (sync flow)
- [ ] Error injection tests (simulate failures)
- [ ] Network condition tests (offline, slow, interrupted)
- [ ] Rollback scenario tests

### Phase 6: Firebase Setup & Deploy (Day 11)

- [ ] Configure Firebase rules
- [ ] Upload initial hymns.json
- [ ] Set up metadata structure
- [ ] Test end-to-end with real Firebase

---

## 📊 Analytics & Monitoring

Track these events in PostHog & Sentry:

```dart
// Success events
- hymns_update_check_success
- hymns_download_started
- hymns_download_completed
- hymns_version_activated

// Error events
- hymns_download_failed (reason, version)
- hymns_validation_failed (layer, reason)
- hymns_rollback_triggered (from_version, to_version)
- hymns_load_failed (source, reason)

// Usage metrics
- current_hymns_version (super property)
- hymns_update_latency (time from check to active)
- hymns_source (current/previous/assets)
```

---

## 🚨 Edge Cases & Handling

| Edge Case                    | Solution                                |
| ---------------------------- | --------------------------------------- |
| Download interrupted mid-way | Write to temp file, validate before use |
| Corrupted download           | Checksum validation catches this        |
| Invalid JSON after update    | Parse validation before activation      |
| Current & previous both fail | Fall back to bundled assets             |
| Assets also corrupted        | Show error, prevent app crash           |
| No internet on first install | Load from bundled assets                |
| Storage full                 | Pre-check available space               |
| Firebase quota exceeded      | Graceful fallback, log error            |
| Version rollback loop        | Blacklist failed versions               |
| User deletes local files     | Regenerate from assets                  |

---

## 🎛️ Configuration Options

Add to `SharedPreferences`:

```dart
class HymnsSyncConfig {
  bool autoUpdateEnabled = true;
  bool updateOnlyOnWifi = false; // Default: updates on any connection (WiFi or mobile data)
  bool showUpdateNotifications = false; // Silent by default
  int updateCheckIntervalHours = 24;
  bool enableVersionRollback = true;
  bool allowBetaVersions = false;
}
```

---

## 📱 User Experience

### Silent Update (Default)

- No interruption to user
- Updates in background
- Subtle one-time notification after successful update (optional)
- Next app launch uses new version seamlessly

### Manual Update (Settings)

- User can check for updates manually
- Shows current vs. available version
- "Update Now" button with progress
- Success confirmation

### Rollback Scenario

- Transparent to user (automatic)
- Subtle notification: "Reverted to previous hymn version"
- Option to report issue

---

## ✅ Success Criteria

1. **Reliability**: 99.9% successful updates without data loss
2. **Safety**: Zero instances of broken hymn data
3. **Performance**: Updates complete within 30 seconds on average WiFi
4. **User Experience**: Completely transparent, no disruption
5. **Recovery**: Automatic rollback within 5 seconds of detecting failure
6. **Monitoring**: All update events tracked in analytics
7. **Bandwidth**: Minimal Firebase usage (only when updates available)

---

## 🚀 Future Enhancements (Optional)

1. **Incremental Updates**: Download only changed hymns (delta sync)
2. **Compression**: Use gzip to reduce 786KB → ~200KB
3. **CDN Fallback**: If Firebase fails, try GitHub raw URL
4. **A/B Testing**: Test new versions with small user percentage
5. **Update Scheduling**: Allow users to set update times
6. **Offline Queue**: Download when WiFi available, activate when ready

---

## 📞 Next Steps

1. **Review this plan** - Any modifications needed?
2. **Firebase setup** - Do you already have Realtime Database enabled?
3. **Start implementation** - Shall I begin with Phase 1?
4. **Testing strategy** - Want to test on a subset of users first?

---

**Ready to proceed when you are! 🚀**
