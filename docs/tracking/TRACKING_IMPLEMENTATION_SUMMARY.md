# PostHog User Tracking Implementation Summary

## 📝 Overview
This document summarizes the comprehensive user tracking implementation added to the Hymnes SDA FR app.

## 🎯 Objectives Achieved
- ✅ Track all users (authenticated and anonymous)
- ✅ Log detailed user properties with every event
- ✅ Enable Daily Active Users (DAU) tracking
- ✅ Track all authentication methods (email, Google, Apple)
- ✅ Include device and platform information in all events

---

## 🔧 Files Modified

### 1. `/lib/core/services/posthog_service.dart`
**Changes:**
- Added device property collection (platform, OS, app version, locale, timezone)
- Enhanced `identifyUser()` method with more parameters:
  - `phoneNumber`
  - `photoUrl`
  - `authProvider` (email, google, apple)
  - `isEmailVerified`
  - Device properties automatically included
- Added `_trackUserSession()` for DAU calculation
- Added `trackAnonymousUserActivity()` for tracking users before login
- Added `updateUserProperties()` for profile updates
- Enhanced `trackEvent()` to include user context automatically
- Updated `trackAppLaunch()` to use dynamic app version and track anonymous users

### 2. `/lib/features/auth/bloc/auth_bloc.dart`
**Changes:**
- Updated `_onSignInRequested` (email login) to track user with full details
- Updated `_onSignUpRequested` (email signup) to track new users
- Updated `_onGoogleSignInRequested` to track Google sign-ins
- Updated `_onAppleSignInRequested` to track Apple sign-ins
- Updated `_onUpdateProfileRequested` to update user properties in PostHog

---

## 📊 Events Being Tracked

### Core Events (Automatic)
| Event Name | When Triggered | Properties Included |
|-----------|---------------|-------------------|
| `app_launched` | App starts | app_version, device_type, platform, OS, locale |
| `anonymous_user_active` | App starts (before login) | distinct_id, timestamp |
| `user_session_started` | User logs in/identified | user_id, session_start, device properties |
| `app_state_changed` | App background/foreground | state, timestamp |

### Authentication Events
| Event Name | When Triggered | Properties Included |
|-----------|---------------|-------------------|
| `auth_login` | User logs in | method (email/google/apple), has_display_name, has_phone, is_email_verified |
| `auth_signup` | User signs up | method, has_phone_number, has_name |
| `auth_logout` | User logs out | - |
| `auth_profile_updated` | Profile updated | updated_name, updated_phone, updated_photo |

### User Properties (Attached to User)
| Property | Description |
|----------|-------------|
| `$email` | User email address |
| `$name` | User display name |
| `phone_number` | User phone number |
| `photo_url` | User profile photo URL |
| `auth_provider` | Authentication method used |
| `is_email_verified` | Email verification status |
| `platform` | Platform (android/ios/web/macos/windows/linux) |
| `os_name` | Operating system name |
| `os_version` | Operating system version |
| `app_version` | App version (e.g., 1.0.1) |
| `app_build` | App build number (e.g., 25) |
| `device_type` | Device type (mobile/desktop/web) |
| `locale` | User locale (e.g., en_US, fr_FR) |
| `timezone` | User timezone |
| `is_debug` | Whether app is in debug mode |

---

## 🚀 How It Works

### 1. **App Launch Flow**
```
App Starts
  ↓
PostHogService.initialize()
  ↓
Collect device properties
  ↓
Setup PostHog config
  ↓
PostHogService.trackAppLaunch()
  ↓
Track 'app_launched' event (with device properties)
  ↓
Track 'anonymous_user_active' event (for DAU)
```

### 2. **User Login Flow (Email)**
```
User enters credentials
  ↓
AuthBloc.SignInRequested
  ↓
AuthService.signInWithEmailAndPassword()
  ↓
PostHogService.identifyUser()
  - userId (Firebase UID)
  - email
  - name
  - phoneNumber
  - photoUrl
  - authProvider = 'email'
  - isEmailVerified
  - device properties
  ↓
PostHogService._trackUserSession() (for DAU)
  ↓
PostHogService.trackAuthEvent('login', method: 'email')
```

### 3. **User Signup Flow**
```
User completes signup form
  ↓
AuthBloc.SignUpRequested
  ↓
AuthService.createUserWithEmailAndPassword()
  ↓
PostHogService.identifyUser()
  - All user properties + device properties
  ↓
PostHogService._trackUserSession()
  ↓
PostHogService.trackAuthEvent('signup', method: 'email')
```

### 4. **Profile Update Flow**
```
User updates profile
  ↓
AuthBloc.UpdateProfileRequested
  ↓
AuthService.updateUserProfile()
  ↓
PostHogService.updateUserProperties()
  ↓
PostHogService.trackAuthEvent('profile_updated')
```

---

## 📈 Viewing Daily Active Users (DAU)

### Quick Steps:
1. Go to PostHog Dashboard: [https://us.i.posthog.com](https://us.i.posthog.com)
2. Click **"Insights"** → **"New Insight"**
3. Select event: `app_launched` or `user_session_started`
4. Aggregation: **"Unique users"**
5. Interval: **"Daily"**
6. Date Range: **"Last 30 days"**

### Result:
You'll see a graph showing Daily Active Users over time, including:
- **Authenticated users** (tracked via `user_session_started`)
- **Anonymous users** (tracked via `anonymous_user_active`)

---

## 🔍 Key Metrics You Can Now Track

### User Metrics
- Daily Active Users (DAU)
- Weekly Active Users (WAU)
- Monthly Active Users (MAU)
- New Signups per Day
- Active Users by Platform (Android, iOS, Web)
- Active Users by Auth Method (Email, Google, Apple)

### Engagement Metrics
- Session Duration
- Hymns Viewed per Session
- Audio Plays per User
- Favorites Added
- Search Queries

### Retention Metrics
- Day 1, 7, 30 Retention
- User Churn Rate
- Time to First Hymn View

---

## ✅ Testing Checklist

### Before Deploying:
- [ ] Run the app and verify no errors
- [ ] Log in with email account and check PostHog "Persons"
- [ ] Log in with Google account and verify tracking
- [ ] Log in with Apple account and verify tracking
- [ ] Update profile and verify properties update in PostHog
- [ ] Check PostHog "Live Events" to see events in real-time
- [ ] Verify device properties are included in events
- [ ] Test on Android device
- [ ] Test on iOS device
- [ ] Test on Web (if applicable)

### After Deploying:
- [ ] Monitor PostHog for incoming events
- [ ] Check DAU metrics after 24 hours
- [ ] Verify user properties are being set correctly
- [ ] Set up DAU dashboard in PostHog
- [ ] Configure alerts for important metrics
- [ ] Share PostHog access with team members

---

## 🐛 Potential Issues & Solutions

### Issue 1: Events not showing in PostHog
**Solution:**
- Check internet connection
- Verify `posthogDebug = true` in `app_configs.dart`
- Check console logs for PostHog errors
- Verify API key is correct
- Check PostHog "Live Events" tab

### Issue 2: User properties not being set
**Solution:**
- Verify `identifyUser()` is being called on login
- Check that user object has all required properties
- Look for errors in PostHog service logs

### Issue 3: DAU count seems low
**Solution:**
- Make sure both `app_launched` and `anonymous_user_active` events are firing
- Check if events are being filtered in PostHog query
- Verify timezone settings match your target audience

### Issue 4: Duplicate events
**Solution:**
- Check if `identifyUser()` is being called multiple times
- Review event tracking logic in auth flows
- Use PostHog's event deduplication features

---

## 📚 Additional Resources

- **Full Tracking Guide**: See `POSTHOG_USER_TRACKING_GUIDE.md`
- **PostHog Documentation**: [https://posthog.com/docs](https://posthog.com/docs)
- **Flutter PostHog Plugin**: [https://pub.dev/packages/posthog_flutter](https://pub.dev/packages/posthog_flutter)

---

## 👨‍💻 Developer Notes

### Adding New Events
To track a new event, use the existing methods in `PostHogService`:

```dart
// Simple event
await PostHogService().trackEvent(
  eventName: 'my_custom_event',
  properties: {
    'property1': 'value1',
    'property2': 'value2',
  },
);

// Hymn event
await PostHogService().trackHymnEvent(
  eventType: 'viewed',
  hymnNumber: '001',
  hymnTitle: 'My Hymn',
);

// Audio event
await PostHogService().trackAudioEvent(
  eventType: 'play',
  hymnNumber: '001',
  duration: 180.0,
);
```

### Updating User Properties
```dart
await PostHogService().updateUserProperties(
  name: 'New Name',
  email: 'newemail@example.com',
  additionalProperties: {
    'custom_property': 'value',
  },
);
```

---

## 🎉 Success!

Your app now has world-class user tracking! You can:
- 📊 See how many users use your app daily
- 🔍 Understand user behavior and preferences
- 📈 Track growth and engagement trends
- 🎯 Make data-driven decisions
- 🚀 Optimize user experience

Start exploring your data in PostHog! 🚀

