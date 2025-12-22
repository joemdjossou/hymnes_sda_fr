#!/usr/bin/env python3
"""
Hymns Metadata Verification Script

This script verifies the checksum and file size of hymns files
from Firebase Storage by comparing them with Firebase Realtime Database metadata.

Usage:
    python scripts/verify_hymns_metadata.py

Requirements:
    pip install requests
"""

import hashlib
import json
import sys
from typing import Dict, Optional
import requests


# Firebase URLs
METADATA_URL = "https://hymnes-sda-fr-default-rtdb.firebaseio.com/hymns_metadata.json"


def calculate_md5_checksum(data: bytes) -> str:
    """Calculate MD5 checksum of data."""
    return hashlib.md5(data).hexdigest()


def fetch_metadata() -> Optional[Dict]:
    """Fetch metadata from Firebase Realtime Database."""
    try:
        response = requests.get(METADATA_URL, timeout=10)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"❌ Error fetching metadata: {e}")
        return None


def download_file(url: str) -> Optional[bytes]:
    """Download file from URL."""
    try:
        print(f"📥 Downloading file from: {url[:80]}...")
        # Ensure UTF-8 encoding is preserved
        response = requests.get(url, timeout=60)
        response.raise_for_status()
        # Ensure response encoding is UTF-8
        response.encoding = 'utf-8'
        return response.content
    except requests.exceptions.RequestException as e:
        print(f"❌ Error downloading file: {e}")
        return None


def verify_metadata(metadata: Dict) -> bool:
    """Verify checksum and file size of downloaded file."""
    print("\n" + "=" * 70)
    print("🔍 HYMNS METADATA VERIFICATION")
    print("=" * 70)
    
    # Display metadata
    print(f"\n📋 Metadata from Firebase:")
    print(f"   Version:        {metadata.get('version', 'N/A')}")
    print(f"   File Size:      {metadata.get('fileSize', 0):,} bytes")
    print(f"   Hymns Count:    {metadata.get('hymnsCount', 0)}")
    print(f"   Checksum:       {metadata.get('checksum', 'N/A')}")
    print(f"   Last Updated:   {metadata.get('lastUpdated', 0)}")
    print(f"   Download URL:   {metadata.get('downloadUrl', 'N/A')[:80]}...")
    
    download_url = metadata.get('downloadUrl')
    if not download_url:
        print("\n❌ No download URL found in metadata!")
        return False
    
    # Download file
    print(f"\n📥 Downloading file...")
    file_data = download_file(download_url)
    if not file_data:
        return False
    
    # Calculate actual values
    actual_size = len(file_data)
    actual_checksum = calculate_md5_checksum(file_data)
    
    # Get expected values
    expected_size = metadata.get('fileSize', 0)
    expected_checksum = metadata.get('checksum', '')
    
    # Verify file size
    print(f"\n📏 File Size Verification:")
    print(f"   Expected: {expected_size:,} bytes")
    print(f"   Actual:   {actual_size:,} bytes")
    
    if expected_size > 0:
        size_diff = abs(actual_size - expected_size)
        size_diff_percent = (size_diff / expected_size) * 100 if expected_size > 0 else 0
        
        if actual_size == expected_size:
            print(f"   ✅ Size matches exactly!")
        elif size_diff_percent <= 5.0:  # Allow 5% variance (more lenient)
            print(f"   ⚠️  Size difference: {size_diff:,} bytes ({size_diff_percent:.2f}%) - Within tolerance")
        else:
            print(f"   ❌ Size mismatch: {size_diff:,} bytes ({size_diff_percent:.2f}%) - Outside tolerance")
            print(f"   💡 Consider updating fileSize in Firebase metadata to: {actual_size}")
            return False
    else:
        print(f"   ⚠️  No expected size in metadata (skipping validation)")
    
    # Verify checksum
    print(f"\n🔐 Checksum Verification:")
    print(f"   Expected: {expected_checksum}")
    print(f"   Actual:   {actual_checksum}")
    
    if expected_checksum:
        if actual_checksum == expected_checksum:
            print(f"   ✅ Checksum matches!")
        else:
            print(f"   ❌ Checksum mismatch!")
            return False
    else:
        print(f"   ⚠️  No checksum in metadata (skipping validation)")
    
    # Try to parse JSON and count hymns (ensure UTF-8 encoding)
    try:
        # Decode bytes to string with UTF-8 encoding to preserve accents
        file_text = file_data.decode('utf-8')
        hymns_data = json.loads(file_text)
        if isinstance(hymns_data, list):
            actual_count = len(hymns_data)
            expected_count = metadata.get('hymnsCount', 0)
            
            print(f"\n📊 Hymns Count Verification:")
            print(f"   Expected: {expected_count}")
            print(f"   Actual:   {actual_count}")
            
            if expected_count > 0:
                if actual_count == expected_count:
                    print(f"   ✅ Count matches!")
                else:
                    count_diff = abs(actual_count - expected_count)
                    count_diff_percent = (count_diff / expected_count) * 100 if expected_count > 0 else 0
                    if count_diff_percent <= 5.0:  # Allow 5% variance
                        print(f"   ⚠️  Count difference: {count_diff} ({count_diff_percent:.2f}%) - Within tolerance")
                    else:
                        print(f"   ❌ Count mismatch: {count_diff} ({count_diff_percent:.2f}%) - Outside tolerance")
                        return False
            else:
                print(f"   ⚠️  No expected count in metadata (skipping validation)")
    except json.JSONDecodeError as e:
        print(f"\n❌ Error parsing JSON: {e}")
        return False
    
    print("\n" + "=" * 70)
    print("✅ VERIFICATION COMPLETE - All checks passed!")
    print("=" * 70)
    return True


def generate_metadata_values(file_path: str) -> Dict:
    """Generate metadata values from a local file."""
    print(f"\n📄 Generating metadata from local file: {file_path}")
    
    try:
        with open(file_path, 'rb') as f:
            file_data = f.read()
        
        # Calculate values
        file_size = len(file_data)
        checksum = calculate_md5_checksum(file_data)
        
        # Parse JSON to count hymns
        try:
            hymns_data = json.loads(file_data.decode('utf-8'))
            hymns_count = len(hymns_data) if isinstance(hymns_data, list) else 0
        except json.JSONDecodeError:
            hymns_count = 0
        
        print(f"\n✅ Generated values:")
        print(f"   File Size:   {file_size:,} bytes")
        print(f"   Checksum:    {checksum}")
        print(f"   Hymns Count: {hymns_count}")
        
        return {
            'fileSize': file_size,
            'checksum': checksum,
            'hymnsCount': hymns_count,
        }
    except FileNotFoundError:
        print(f"❌ File not found: {file_path}")
        return {}
    except Exception as e:
        print(f"❌ Error processing file: {e}")
        return {}


def main():
    """Main function."""
    print("🎵 Hymns Metadata Verification Script")
    print("=" * 70)
    
    # Check if user wants to generate values from local file
    if len(sys.argv) > 1:
        file_path = sys.argv[1]
        values = generate_metadata_values(file_path)
        if values:
            print("\n📋 Use these values in Firebase metadata:")
            print(json.dumps(values, indent=2))
        return
    
    # Fetch and verify metadata
    metadata = fetch_metadata()
    if not metadata:
        print("\n❌ Failed to fetch metadata. Exiting.")
        sys.exit(1)
    
    success = verify_metadata(metadata)
    
    if not success:
        print("\n❌ Verification failed. Please check the errors above.")
        sys.exit(1)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n⚠️  Interrupted by user")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ Unexpected error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

