# Scripts Directory

Utility scripts for managing and verifying hymns data.

---

## 📋 Available Scripts

### `verify_hymns_metadata.py`

Verifies checksum and file size of hymns files from Firebase Storage by comparing them with Firebase Realtime Database metadata.

#### Usage:

**1. Verify Firebase metadata:**
```bash
python3 scripts/verify_hymns_metadata.py
```

This will:
- Fetch metadata from Firebase Realtime Database
- Download the hymns file from Firebase Storage
- Calculate actual checksum and file size
- Compare with metadata values
- Report any mismatches

**2. Generate metadata values from local file:**
```bash
python3 scripts/verify_hymns_metadata.py assets/data/hymns.json
```

This will:
- Read your local `hymns.json` file
- Calculate file size, checksum, and hymn count
- Display values you can use in Firebase metadata

#### Requirements:
```bash
pip install requests
```

#### Example Output:

```
🎵 Hymns Metadata Verification Script
======================================================================

======================================================================
🔍 HYMNS METADATA VERIFICATION
======================================================================

📋 Metadata from Firebase:
   Version:        1.0.5
   File Size:      812,059 bytes
   Hymns Count:    654
   Checksum:       c5af6e54c08293cfc500ba85b9a10be0
   ...

📏 File Size Verification:
   Expected: 812,059 bytes
   Actual:   786,000 bytes
   ⚠️  Size difference: 26,059 bytes (3.21%) - Within tolerance

🔐 Checksum Verification:
   Expected: c5af6e54c08293cfc500ba85b9a10be0
   Actual:   c5af6e54c08293cfc500ba85b9a10be0
   ✅ Checksum matches!

✅ VERIFICATION COMPLETE - All checks passed!
```

---

## 🔧 Troubleshooting

### "ModuleNotFoundError: No module named 'requests'"
```bash
pip install requests
```

### "File not found"
Make sure you're running from the project root directory:
```bash
cd /path/to/hymnes_sda_fr
python3 scripts/verify_hymns_metadata.py
```

### Size/Checksum Mismatch
If verification fails:
1. Check the actual values reported by the script
2. Update Firebase metadata with correct values
3. Re-run verification

---

## 📝 Notes

- The script allows up to **5% variance** in file size (to account for compression, encoding differences)
- Checksum validation is strict (must match exactly if provided)
- Hymn count allows **5% variance** (to account for data changes)

