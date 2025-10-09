# Firestore Favorites Integration

This document explains the implementation of Firestore integration for user favorites in the Hymnes SDA FR app.

## Overview

The app now supports storing user favorites both locally (using ObjectBox) and in the cloud (using Firestore). This provides:

- **Offline-first functionality**: Favorites work even without internet connection
- **Cloud synchronization**: Favorites are synced across devices when users are authenticated
- **Automatic sync**: Favorites are automatically synced when users sign in/out
- **Conflict resolution**: Smart merging of local and cloud favorites based on timestamps

## Architecture

### Components

1. **`FirestoreFavoritesRepository`**: Handles all Firestore operations
2. **`HybridFavoritesRepository`**: Combines local and cloud storage with smart sync logic
3. **`FavoritesSyncService`**: Manages authentication state changes and automatic sync
4. **Updated `FavoritesBloc`**: Uses hybrid repository and provides sync events

### Data Flow

```
User Action → FavoritesBloc → HybridFavoritesRepository → {
  Local Storage (ObjectBox) ← Always
  Firestore ← When authenticated & online
}
```

## Implementation Details

### 1. FirestoreFavoritesRepository

**Location**: `lib/core/repositories/firestore_favorites_repository.dart`

**Key Features**:

- User-specific collections: `users/{userId}/user_favorites`
- Document ID is the hymn number for easy lookup
- Server timestamps for conflict resolution
- Real-time listeners for live updates

**Firestore Structure**:

```
users/
  {userId}/
    user_favorites/
      {hymnNumber}/
        - hymn data (title, lyrics, author, etc.)
        - dateAdded: serverTimestamp
        - userId: string
```

### 2. HybridFavoritesRepository

**Location**: `lib/core/repositories/hybrid_favorites_repository.dart`

**Key Features**:

- Offline-first approach: always saves locally first
- Smart sync logic based on timestamps
- Graceful fallback when cloud operations fail
- Network status awareness

**Sync Logic**:

1. Always save to local storage first
2. If online and authenticated, also save to Firestore
3. On load, compare local vs cloud timestamps
4. Sync the newer data to the older source

### 3. FavoritesSyncService

**Location**: `lib/core/services/favorites_sync_service.dart`

**Key Features**:

- Listens to authentication state changes
- Automatically syncs on sign in
- Preserves local favorites on sign out
- Provides sync status information

### 4. Updated FavoritesBloc

**Location**: `lib/features/favorites/bloc/favorites_bloc.dart`

**New Events**:

- `SyncFavorites`: Manual sync trigger
- `ForceSyncFavorites`: Force sync regardless of timestamps
- `SetOnlineStatus`: Update network status

**New State Properties**:

- `isOnline`: Network connectivity status
- `isAuthenticated`: User authentication status
- `isSynced`: Whether local and cloud are in sync

## Usage

### Basic Usage

The integration is automatic. Users don't need to do anything special:

1. **Adding Favorites**: Works offline and online
2. **Removing Favorites**: Works offline and online
3. **Viewing Favorites**: Always shows local favorites, syncs in background
4. **Sign In**: Automatically syncs favorites from cloud
5. **Sign Out**: Keeps local favorites, stops cloud sync

### Manual Sync

If needed, you can trigger manual sync:

```dart
// In your widget
context.read<FavoritesBloc>().add(const SyncFavorites());

// Or force sync
context.read<FavoritesBloc>().add(const ForceSyncFavorites());
```

### Checking Sync Status

```dart
// In your widget
BlocBuilder<FavoritesBloc, FavoritesState>(
  builder: (context, state) {
    if (state is FavoritesLoaded) {
      return Column(
        children: [
          Text('Online: ${state.isOnline}'),
          Text('Authenticated: ${state.isAuthenticated}'),
          Text('Synced: ${state.isSynced}'),
        ],
      );
    }
    return const SizedBox.shrink();
  },
)
```

## Configuration

### Firebase Setup

Ensure your Firebase project is configured with:

1. **Firestore Database**: Enabled with appropriate security rules
2. **Authentication**: Configured with your preferred providers
3. **Security Rules**: Allow authenticated users to read/write their own favorites

### Security Rules Example

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own favorites
    match /users/{userId}/user_favorites/{hymnNumber} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Error Handling

The implementation includes comprehensive error handling:

1. **Network Errors**: Falls back to local storage
2. **Authentication Errors**: Continues with local-only mode
3. **Firestore Errors**: Logs errors and continues with local storage
4. **Sync Conflicts**: Uses timestamp-based resolution

## Testing

### Unit Tests

Run the test suite:

```bash
flutter test test/unit/repositories/hybrid_favorites_repository_test.dart
```

### Integration Testing

1. **Offline Testing**: Disable network, add/remove favorites
2. **Online Testing**: Enable network, test sync behavior
3. **Authentication Testing**: Sign in/out, verify sync behavior
4. **Conflict Testing**: Modify favorites on multiple devices

## Performance Considerations

1. **Local First**: All operations are fast due to local storage
2. **Background Sync**: Cloud operations don't block UI
3. **Efficient Queries**: Uses hymn number as document ID for O(1) lookups
4. **Minimal Data**: Only stores necessary hymn data in Firestore

## Troubleshooting

### Common Issues

1. **Favorites not syncing**: Check authentication status and network connectivity
2. **Duplicate favorites**: Ensure proper conflict resolution logic
3. **Slow performance**: Check Firestore security rules and network conditions

### Debug Information

Enable debug logging to see sync operations:

```dart
// The repositories use Logger for debug information
// Check console output for sync-related logs
```

## Future Enhancements

Potential improvements:

1. **Batch Operations**: Group multiple favorite changes for efficiency
2. **Incremental Sync**: Only sync changed favorites
3. **Offline Queue**: Queue operations when offline, sync when online
4. **User Preferences**: Allow users to choose sync behavior
5. **Backup/Restore**: Export/import favorites functionality

## Migration

### From Local-Only to Hybrid

The implementation is backward compatible:

1. Existing local favorites are preserved
2. First sign-in will sync local favorites to cloud
3. No data loss during migration

### Data Migration

If you need to migrate existing data:

```dart
// Example migration code
final localFavorites = await localRepository.getFavorites();
for (final favorite in localFavorites) {
  await firestoreRepository.addToFavorites(favorite.hymn);
}
```

## Conclusion

The Firestore integration provides a robust, offline-first solution for user favorites with seamless cloud synchronization. The implementation follows best practices for mobile app data management and provides excellent user experience across all network conditions.
