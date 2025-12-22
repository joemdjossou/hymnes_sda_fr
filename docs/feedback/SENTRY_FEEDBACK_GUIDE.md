# Viewing User Feedback in Sentry

## ✅ Updated Implementation

I've updated the Sentry integration to properly send user feedback with full context. Here's what's included with each feedback submission:

### What's Sent to Sentry:

1. **User Information**

   - User ID (Firebase UID)
   - Email address
   - Name

2. **Feedback Details**

   - Feedback type (bug, feature, review, general)
   - User message
   - Timestamp

3. **Device & App Context**

   - Platform (Android, iOS, Web, etc.)
   - OS name and version
   - App version and build number
   - Device type (mobile, desktop, web)
   - Locale and timezone

4. **Tags for Easy Filtering**
   - `feedback_type` - Filter by bug/feature/review/general
   - `platform` - Filter by Android/iOS/Web
   - `app_version` - Filter by app version

---

## 📊 How to View Feedback in Sentry

### Option 1: View All Feedback (Recommended)

1. **Go to your Sentry Dashboard**

   - Navigate to your Hymnes SDA project

2. **Go to Issues**

   - Click on **"Issues"** in the left sidebar

3. **Filter by Feedback**

   - In the search bar, type: `feedback_type:*`
   - Or search for specific types:
     - `feedback_type:bug` - Only bug reports
     - `feedback_type:feature` - Only feature requests
     - `feedback_type:review` - Only reviews
     - `feedback_type:general` - Only general feedback

4. **View Feedback Details**
   - Click on any issue to see:
     - Full feedback message (in the event title)
     - User information (name, email, ID)
     - Device details (platform, OS, app version)
     - Timestamp

### Option 2: Create a Custom Search

Save a search query for quick access:

```
feedback_type:* level:info
```

This will show all feedback regardless of type.

### Option 3: Set Up Alerts

Create alerts for specific feedback types:

1. Go to **Alerts** → **Create Alert**
2. Set condition: `Tags contain feedback_type:bug`
3. Get notified immediately when users report bugs!

---

## 🔍 Understanding the Feedback Format

Each feedback appears in Sentry with this format:

**Title:** `[bug] The app crashes when I tap the favorite button`

**User Context:**

```
User ID: abc123xyz
Email: user@example.com
Name: John Doe
```

**Device Context:**

```
Platform: android
OS: Android 14
App Version: 1.0.1 (25)
Device Type: mobile
Locale: fr_FR
```

**Feedback Context:**

```
Message: "The app crashes when I tap the favorite button"
Timestamp: 2025-11-17T12:30:45.123Z
Type: bug
```

---

## 📈 Analyzing Feedback Trends

### Group by Feedback Type

1. In Issues, click **"Group By"**
2. Select **"Tags"** → **"feedback_type"**
3. See distribution of bugs vs features vs reviews

### Filter by Platform

1. Search: `feedback_type:bug platform:android`
2. See all Android-specific bugs

### Filter by App Version

1. Search: `feedback_type:* app_version:1.0.1`
2. See all feedback for a specific app version

---

## 🎯 Best Practices

### 1. **Monitor Bug Reports Daily**

Set up email alerts for `feedback_type:bug` to respond quickly to issues.

### 2. **Track Feature Requests**

Create a saved search for `feedback_type:feature` to build your roadmap.

### 3. **Acknowledge Reviews**

Check `feedback_type:review` regularly to understand user sentiment.

### 4. **Cross-Reference with PostHog**

- Sentry: See what users are saying
- PostHog: See how many users are affected

### 5. **Link to Issues**

When you fix a bug reported via feedback, link the Sentry issue to your GitHub/Jira issue for tracking.

---

## 🔧 Troubleshooting

### "I don't see any feedback in Sentry"

**Check:**

1. ✅ Is Sentry properly initialized in `main.dart`?
2. ✅ Did you test the feedback form in your app?
3. ✅ Search for `feedback_type:*` in Issues
4. ✅ Check the date range filter (last 24 hours, 7 days, etc.)

### "Feedback appears but without user details"

This happens when users submit feedback before logging in. The feedback will show:

- User: "Anonymous User"
- Email: (empty)
- User ID: "anonymous"

---

## 📊 Sample Queries

### All Feedback

```
feedback_type:*
```

### Bug Reports Only

```
feedback_type:bug
```

### Feature Requests Only

```
feedback_type:feature
```

### Android Bugs

```
feedback_type:bug platform:android
```

### iOS Feature Requests

```
feedback_type:feature platform:ios
```

### Recent Feedback (Last 24 Hours)

```
feedback_type:* age:-24h
```

### High-Priority (Error Level)

```
feedback_type:bug level:error
```

---

## 🚀 Advanced: Sentry User Feedback Widget

If you want to use Sentry's official feedback widget in the future (more visual, includes screenshots), you can implement it like this:

```dart
// In your error handler or specific screens
import 'package:sentry_flutter/sentry_flutter.dart';

// Show the widget
final context = navigatorKey.currentContext;
if (context != null && context.mounted) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => SentryFeedbackWidget(
        // Optional: associate with a specific event
        // associatedEventId: eventId,
      ),
      fullscreenDialog: true,
    ),
  );
}
```

This provides a more polished UI but requires additional setup.

---

## ✅ Summary

Your feedback is now properly sent to Sentry with:

- ✅ Full user context
- ✅ Device and app information
- ✅ Filterable tags
- ✅ Structured contexts
- ✅ No deprecation warnings

**To view feedback:**

1. Go to Sentry Dashboard
2. Navigate to **Issues**
3. Search: `feedback_type:*`
4. Click any issue to see full details

**Your feedback system is now fully operational in both PostHog and Sentry!** 🎉
