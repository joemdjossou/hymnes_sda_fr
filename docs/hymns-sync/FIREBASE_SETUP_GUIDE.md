# Firebase Setup Guide for Hymns Sync

## Step-by-Step Instructions

---

## 📋 Prerequisites

- ✅ You already have Firebase project (you're using Firebase Auth)
- ✅ Your app is connected to Firebase
- ⏱️ Time needed: ~15 minutes

---

## Part 1: Firebase Realtime Database Setup

### Step 1: Open Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **"hymnes_sda_fr"** (or your project name)

### Step 2: Navigate to Realtime Database

1. In the left sidebar, click **"Build"**
2. Click **"Realtime Database"**
3. You'll see either:
   - **"Create Database"** button (if not created yet)
   - OR your existing database

### Step 3: Create Database (if needed)

If you see "Create Database" button:

1. Click **"Create Database"**
2. Choose database location:

   - **United States** (us-central1) - Good for global
   - **Europe** (europe-west1) - Good for Europe/Africa
   - **Asia** (asia-southeast1) - Good for Asia

   💡 **Recommendation**: Choose **United States** for best global coverage

3. Security rules dialog appears:
   - Select **"Start in test mode"** (we'll secure it next)
   - Click **"Enable"**

### Step 4: Set Security Rules

Once database is created:

1. Click the **"Rules"** tab at the top
2. You'll see default rules like:

   ```json
   {
     "rules": {
       ".read": "now < 1234567890000",
       ".write": "now < 1234567890000"
     }
   }
   ```

3. **Replace ALL content** with this:

   ```json
   {
     "rules": {
       "hymns_metadata": {
         ".read": true,
         ".write": false
       }
     }
   }
   ```

4. Click **"Publish"** button
5. You should see: ✅ "Rules published successfully"

### Step 5: Verify Database URL

1. Click the **"Data"** tab
2. Look at the top - you'll see your database URL:
   ```
   https://YOUR-PROJECT-ID-default-rtdb.firebaseio.com/
   ```
3. ✅ Keep this URL handy (you'll need it for testing)

---

## Part 2: Firebase Storage Setup

### Step 1: Navigate to Storage

1. In Firebase Console left sidebar, under **"Build"**
2. Click **"Storage"**
3. You'll see either:
   - **"Get started"** button (if not created yet)
   - OR your existing storage bucket

### Step 2: Create Storage (if needed)

If you see "Get started" button:

1. Click **"Get started"**
2. Security rules dialog appears:

   - Select **"Start in test mode"** (we'll secure it next)
   - Click **"Next"**

3. Choose location:

   - Use **SAME location** as your Realtime Database
   - Click **"Done"**

4. Wait ~30 seconds for bucket creation

### Step 3: Set Security Rules

1. Click the **"Rules"** tab at the top
2. You'll see default rules like:

   ```
   rules_version = '2';
   service firebase.storage {
     match /b/{bucket}/o {
       match /{allPaths=**} {
         allow read, write: if request.time < timestamp...;
       }
     }
   }
   ```

3. **Replace ALL content** with this:

   ```
   rules_version = '2';
   service firebase.storage {
     match /b/{bucket}/o {
       match /hymns/{fileName} {
         allow read: if true;
         allow write: if false;
       }
     }
   }
   ```

4. Click **"Publish"** button
5. You should see: ✅ "Rules published successfully"

### Step 4: Create Hymns Folder

1. Click the **"Files"** tab at the top
2. You'll see your bucket (e.g., `your-project.appspot.com`)
3. Click the **folder icon** (📁) or look for "Create folder"
4. Name it: `hymns`
5. Click **"Create"** or press Enter

---

## Part 3: Upload Initial Hymns Version

### Step 1: Prepare Your Hymns File

1. Locate your hymns file:

   ```
   /Users/joemdjossou/Documents/GitHub/hymnes_sda_fr/assets/data/hymns.json
   ```

2. **Important**: Rename a COPY for upload:
   - Original: `hymns.json`
   - Copy and rename to: `hymns_v1.0.0.json`

### Step 2: Upload to Firebase Storage

1. In Firebase Console → Storage → Files tab
2. Click on the `hymns` folder to open it
3. Click **"Upload file"** button
4. Select your `hymns_v1.0.0.json` file
5. Wait for upload to complete (should take ~10-30 seconds for 786 KB)
6. You'll see: ✅ "Upload complete"

### Step 3: Get Download URL

1. In the file list, find `hymns_v1.0.0.json`
2. Click on the file name to open details
3. Look for **"Download URL"** or "Access token"
4. Click the **copy icon** (📋) next to the URL
5. The URL looks like:
   ```
   https://firebasestorage.googleapis.com/v0/b/your-project.appspot.com/o/hymns%2Fhymns_v1.0.0.json?alt=media&token=abc123...
   ```
6. **SAVE THIS URL** - you'll need it in next step!

---

## Part 4: Create Metadata in Realtime Database

### Step 1: Calculate Required Values

We need 4 values for the metadata. Let me help you get them:

#### A. File Size (bytes)

**Option 1 - From Firebase Console:**

1. In Storage → Files → hymns folder
2. Look at your uploaded file
3. You'll see size like "786 KB"
4. Convert to bytes: 786 × 1024 = **804,864 bytes**

**Option 2 - From Terminal:**

```bash
cd /Users/joemdjossou/Documents/GitHub/hymnes_sda_fr/assets/data
ls -l hymns.json
```

Look for the number before the date (e.g., 804864)

#### B. Hymns Count

**Option 1 - Quick Check:**

1. Open `hymns.json` in your editor
2. It's a JSON array `[...]`
3. Each hymn is an object `{...}`
4. Count objects or use search

**Option 2 - Terminal:**

```bash
cd /Users/joemdjossou/Documents/GitHub/hymnes_sda_fr/assets/data
grep -o '"number"' hymns.json | wc -l
```

This counts how many times "number" appears = number of hymns

**Your file probably has around 850 hymns** (based on 786 KB size)

#### C. MD5 Checksum

**Option 1 - Terminal (Mac/Linux):**

```bash
cd /Users/joemdjossou/Documents/GitHub/hymnes_sda_fr/assets/data
md5 hymns.json
```

**Option 2 - Online Tool:**

1. Go to: https://emn178.github.io/online-tools/md5_checksum.html
2. Click "Choose File"
3. Select your `hymns.json`
4. Copy the MD5 hash (32 characters like: `a3f5e8d9b2c7e1f4...`)

#### D. Current Timestamp

**In Browser Console (any browser):**

1. Press `F12` or `Cmd+Option+I` (Mac)
2. Click "Console" tab
3. Type: `Date.now()`
4. Press Enter
5. Copy the number (e.g., `1732123456789`)

### Step 2: Create Metadata Structure

1. Go to Firebase Console → Realtime Database → Data tab
2. You'll see the root of your database (empty or with existing data)
3. Hover over the database name (root) and click the **"+"** button
4. In the dialog:

   - **Name**: `hymns_metadata`
   - **Value**: Leave empty for now
   - Click **"Add"**

5. Now hover over `hymns_metadata` and click **"+"** to add fields

Add these fields ONE BY ONE (click "+" between each):

| Name            | Type   | Value                                         |
| --------------- | ------ | --------------------------------------------- |
| `version`       | string | `1.0.0`                                       |
| `lastUpdated`   | number | `YOUR_TIMESTAMP` (from Step 1D)               |
| `downloadUrl`   | string | `YOUR_DOWNLOAD_URL` (from Part 3, Step 3)     |
| `fileSize`      | number | `YOUR_FILE_SIZE` (from Step 1A, e.g., 804864) |
| `hymnsCount`    | number | `YOUR_HYMN_COUNT` (from Step 1B, e.g., 850)   |
| `checksum`      | string | `YOUR_MD5_HASH` (from Step 1C)                |
| `minAppVersion` | string | `1.0.0`                                       |
| `releaseNotes`  | string | `Initial version` (optional)                  |

**Example of what it should look like:**

```json
{
  "hymns_metadata": {
    "version": "1.0.0",
    "lastUpdated": 1732123456789,
    "downloadUrl": "https://firebasestorage.googleapis.com/.../hymns_v1.0.0.json?alt=media&token=...",
    "fileSize": 804864,
    "hymnsCount": 850,
    "checksum": "a3f5e8d9b2c7e1f4d6a8b9c0e2f1d3e5",
    "minAppVersion": "1.0.0",
    "releaseNotes": "Initial version"
  }
}
```

---

## Part 5: Test Your Setup

### Step 1: Verify Database Access

1. Open this URL in your browser (replace with YOUR database URL):

   ```
   https://YOUR-PROJECT-ID-default-rtdb.firebaseio.com/hymns_metadata.json
   ```

2. You should see your metadata JSON displayed
3. If you see "Permission denied" → Check your database rules (Part 1, Step 4)

### Step 2: Verify Storage Access

1. Copy your download URL (from metadata)
2. Paste it in a new browser tab
3. The file should download or display
4. If you see "Access denied" → Check your storage rules (Part 2, Step 3)

### Step 3: Test in Your App

1. Make sure you ran `flutter pub get`
2. Run your app:

   ```bash
   cd /Users/joemdjossou/Documents/GitHub/hymnes_sda_fr
   flutter run
   ```

3. Watch the logs for:

   ```
   [HymnsSyncService] HymnsSyncService initialized
   [HymnsSyncService] No local metadata found, initializing...
   [HymnsSyncService] Checking for updates...
   [HymnsSyncService] Fetched remote metadata: RemoteHymnsMetadata(version: 1.0.0, ...)
   ```

4. After ~5 seconds, you should see:
   - If versions match: `No update needed. Current: 1.0.0, Remote: 1.0.0`
   - If remote is newer: `Downloading hymns version 1.0.0`

### Step 4: Check Settings UI

1. In your app, navigate to **Settings**
2. Scroll to **"Hymns Data"** section
3. You should see:

   - Current Version: 1.0.0
   - Previous Version: None
   - Status: stable
   - Storage: ~786 KB

4. Tap **"Check Updates"** button
5. Should show: "Already up to date" or "No update needed"

---

## 🎉 Setup Complete!

You've successfully configured:

- ✅ Firebase Realtime Database with public read access
- ✅ Firebase Storage with public read access
- ✅ Uploaded your first hymns version
- ✅ Created metadata structure
- ✅ Tested the sync system

---

## 🚀 Next: How to Push Updates

When you want to update your hymns (add new ones, fix errors, etc.):

### Method 1: Manual (Recommended)

1. **Update your local hymns.json** with changes
2. **Increment version**: `1.0.0` → `1.0.1` or `1.1.0`
3. **Upload to Storage**:

   - Copy and rename: `hymns_v1.0.1.json`
   - Upload to Firebase Storage → hymns folder
   - Get new download URL

4. **Update Realtime Database**:

   - Go to Database → Data → hymns_metadata
   - Update these fields:
     - `version`: `1.0.1`
     - `lastUpdated`: New timestamp (use `Date.now()`)
     - `downloadUrl`: New file's URL
     - `fileSize`: New file size
     - `hymnsCount`: New hymn count
     - `checksum`: New MD5 hash
     - `releaseNotes`: "Added 5 new hymns" (optional)

5. **Done!** Within 24 hours, all users will auto-update

### Method 2: Programmatic (Advanced)

Use the `FirebaseHymnsHelper` class in a separate admin app or script:

```dart
// This requires Firebase Admin authentication
import 'package:hymnes_sda_fr/core/services/firebase_hymns_helper.dart';

void main() async {
  // Upload file
  final url = await FirebaseHymnsHelper.uploadHymnsToStorage(
    version: '1.0.1',
    localFilePath: 'path/to/hymns.json',
  );

  // Update metadata
  if (url != null) {
    await FirebaseHymnsHelper.updateMetadataInDatabase(
      version: '1.0.1',
      downloadUrl: url,
      fileSize: 850000,
      hymnsCount: 855,
      checksum: 'new_checksum',
      releaseNotes: 'Added 5 new hymns',
    );
  }
}
```

---

## 🐛 Troubleshooting

### Issue: "Permission denied" in Database

**Solution:**

1. Firebase Console → Realtime Database → Rules
2. Make sure rules are:
   ```json
   {
     "rules": {
       "hymns_metadata": {
         ".read": true,
         ".write": false
       }
     }
   }
   ```
3. Click "Publish"
4. Wait 30 seconds for rules to propagate

### Issue: "Access denied" in Storage

**Solution:**

1. Firebase Console → Storage → Rules
2. Make sure rules include:
   ```
   match /hymns/{fileName} {
     allow read: if true;
     allow write: if false;
   }
   ```
3. Click "Publish"
4. Wait 30 seconds

### Issue: App says "Failed to fetch remote metadata"

**Causes:**

- Database rules not set correctly
- `hymns_metadata` node doesn't exist
- Database not enabled

**Check:**

1. Open in browser: `https://YOUR-DB.firebaseio.com/hymns_metadata.json`
2. Should see your JSON data
3. If empty → Recreate metadata (Part 4)
4. If permission denied → Fix rules (Part 1, Step 4)

### Issue: "Validation failed" after download

**Causes:**

- File size in metadata doesn't match actual file
- Checksum is wrong
- Hymn count is wrong

**Solution:**

1. Recalculate all values (Part 4, Step 1)
2. Update metadata in Database
3. Try again

### Issue: Download never starts

**Check:**

1. Device has internet connection
2. If "updateOnlyOnWifi" is true → Make sure on WiFi
3. Check app logs for error messages

---

## 📊 Monitoring Your Sync System

### Check Realtime Database Usage

1. Firebase Console → Realtime Database → Usage tab
2. Monitor:
   - Download: Should be minimal (metadata is tiny)
   - Storage: Very low
   - Connections: One per active user checking for updates

### Check Storage Usage

1. Firebase Console → Storage → Usage tab
2. Monitor:
   - Storage: ~1-2 MB per version (keep 2-3 versions max)
   - Download: ~786 KB per user per update
   - Network egress: Track monthly downloads

**Free tier limits:**

- Database: 1 GB stored, 10 GB/month download ✅ (More than enough)
- Storage: 5 GB stored, 1 GB/day download ✅ (Good for ~1,300 updates/day)

---

## 🎓 Best Practices

### Version Numbering

Use semantic versioning:

- `1.0.0` → `1.0.1` - Bug fixes, minor changes
- `1.0.0` → `1.1.0` - New features (new hymns)
- `1.0.0` → `2.0.0` - Major changes (restructure)

### File Naming

Keep old versions in Storage for rollback:

- `hymns_v1.0.0.json` ← Original
- `hymns_v1.0.1.json` ← Bug fix
- `hymns_v1.1.0.json` ← Added hymns

Delete very old versions (3+ releases old) to save space

### Testing Updates

Before pushing to production:

1. Test locally with small changes
2. Verify validation passes
3. Check rollback works
4. Test on real device
5. Monitor first few hours after release

### Release Notes

Make them user-friendly:

- ✅ "Added 5 new hymns (nos. 851-855)"
- ✅ "Fixed lyrics for hymn #234"
- ✅ "Updated MIDI files for 10 hymns"
- ❌ "Bug fixes and improvements" (too vague)

---

## ✅ Quick Reference

### Firebase Console URLs:

- Database: https://console.firebase.google.com/project/YOUR-PROJECT/database
- Storage: https://console.firebase.google.com/project/YOUR-PROJECT/storage

### Important Paths:

- Storage folder: `/hymns/`
- Database node: `/hymns_metadata/`

### Version Format:

```json
{
  "version": "1.0.0",
  "lastUpdated": 1732123456789,
  "downloadUrl": "https://...",
  "fileSize": 804864,
  "hymnsCount": 850,
  "checksum": "abc123...",
  "minAppVersion": "1.0.0"
}
```

---

**Need more help?** Let me know which step you're stuck on! 🚀
