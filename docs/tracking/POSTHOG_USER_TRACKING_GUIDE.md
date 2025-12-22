# PostHog User Tracking Guide

## Overview
This guide explains how to track users, monitor Daily Active Users (DAU), and analyze user behavior in your Hymnes SDA FR app using PostHog.

## 📊 What's Being Tracked

### 1. **User Identification**
Every user is tracked with comprehensive details:
- **User ID** (Firebase UID)
- **Email**
- **Display Name**
- **Phone Number**
- **Photo URL**
- **Authentication Provider** (email, google, apple)
- **Email Verification Status**
- **Device Properties** (platform, OS, app version)
- **Location Data** (locale, timezone)

### 2. **Automatic Events**
The following events are tracked automatically:

#### App Lifecycle Events
- `app_launched` - Fired when app starts (includes app version, device info)
- `app_state_changed` - Fired when app goes to background/foreground
- `anonymous_user_active` - Tracks DAU for users before they log in
- `user_session_started` - Tracks authenticated user sessions

#### Authentication Events
- `auth_signup` (method: email, google, apple)
- `auth_login` (method: email, google, apple)
- `auth_logout`
- `auth_profile_updated`

#### Hymn Interaction Events
- `hymn_viewed`
- `hymn_favorited`
- `hymn_unfavorited`

#### Audio Events
- `audio_play`
- `audio_pause`
- (includes hymn number, duration, position)

#### Search Events
- `search_performed` (includes query, result count)

#### Navigation Events
- Screen transitions are tracked automatically

### 3. **Device & Platform Properties**
Every event includes:
- **Platform**: web, android, ios, macos, windows, linux
- **OS Name & Version**
- **App Version & Build Number**
- **Device Type**: mobile, desktop, web
- **Locale** (e.g., en_US, fr_FR)
- **Timezone**
- **Debug Mode** (true/false)

---

## 📈 How to View Daily Active Users (DAU) in PostHog

### Method 1: Using the Insights Dashboard

1. **Go to PostHog Dashboard** → [https://us.i.posthog.com](https://us.i.posthog.com)
2. Click on **"Insights"** in the left sidebar
3. Click **"New Insight"**
4. Select **"Trends"** as the insight type
5. Configure the query:
   - **Event**: Select `app_launched` or `user_session_started`
   - **Aggregation**: Select "Unique users"
   - **Date Range**: Last 7 days, 30 days, or custom
   - **Interval**: Daily
6. Click **"Calculate"**

You'll see a graph showing Daily Active Users over time.

### Method 2: Create a Custom DAU Dashboard

1. Go to **"Dashboards"** → **"New Dashboard"**
2. Name it "User Metrics Dashboard"
3. Add the following insights:

#### DAU Insight
- **Name**: Daily Active Users
- **Event**: `app_launched` or `user_session_started`
- **Unique users**: Daily
- **Date Range**: Last 30 days

#### WAU Insight (Weekly Active Users)
- **Name**: Weekly Active Users
- **Event**: `app_launched`
- **Unique users**: Weekly
- **Date Range**: Last 12 weeks

#### MAU Insight (Monthly Active Users)
- **Name**: Monthly Active Users
- **Event**: `app_launched`
- **Unique users**: Monthly
- **Date Range**: Last 12 months

#### User Retention
- **Type**: Retention
- **Performed**: `auth_signup` or `auth_login`
- **Came back**: `app_launched`
- **Period**: Daily/Weekly

### Method 3: Using Cohorts

1. Go to **"Cohorts"** → **"New Cohort"**
2. Create cohorts for different user segments:
   - **Active Today**: Users who triggered `app_launched` in the last 24 hours
   - **Active This Week**: Users who triggered `app_launched` in the last 7 days
   - **New Users**: Users who triggered `auth_signup` in the last 7 days
   - **By Platform**: Filter by `platform` property (android, ios, web)
   - **By Auth Method**: Filter by `auth_provider` (email, google, apple)

---

## 🔍 Advanced Analytics Queries

### 1. **Track User Engagement by Platform**
```sql
Event: app_launched
Breakdown by: platform
Graph Type: Stacked Area Chart
```

### 2. **Most Popular Hymns**
```sql
Event: hymn_viewed
Breakdown by: hymn_number
Aggregation: Count of events
Order by: Descending
Top: 20
```

### 3. **Audio Playback Analysis**
```sql
Event: audio_play
Properties to view: hymn_number, duration, voice_type
```

### 4. **User Acquisition Funnel**
Create a funnel with these steps:
1. `app_launched` (First visit)
2. `hymn_viewed` (Engagement)
3. `auth_signup` (Conversion)

### 5. **Session Duration**
Use PostHog's built-in session recording and tracking to see:
- Average session duration
- Session count per user
- Time between sessions

---

## 👥 Analyzing User Properties

### View Individual User Profiles
1. Go to **"Persons"** in PostHog
2. Click on any user to see:
   - All their properties (email, name, device, etc.)
   - Timeline of all events they've triggered
   - Session recordings (if enabled)
   - Feature flags assigned to them

### Filter Users by Properties
Create segments based on:
- **Platform**: `platform = "android"`
- **Auth Method**: `auth_provider = "google"`
- **Email Verified**: `is_email_verified = true`
- **App Version**: `$app_version = "1.0.1"`

---

## 📊 Key Metrics to Monitor

### Growth Metrics
- **DAU** (Daily Active Users)
- **WAU** (Weekly Active Users)
- **MAU** (Monthly Active Users)
- **New Signups per Day/Week/Month**

### Engagement Metrics
- **Average Session Duration**
- **Hymns Viewed per Session**
- **Audio Plays per User**
- **Search Queries per Session**
- **Favorites Added per User**

### Retention Metrics
- **Day 1 Retention**: % of users who return the day after signup
- **Day 7 Retention**: % of users who return 7 days after signup
- **Day 30 Retention**: % of users who return 30 days after signup

### Conversion Metrics
- **Anonymous → Signup Conversion Rate**
- **Time to First Hymn View**
- **Time to First Audio Play**
- **Time to First Favorite**

### Platform Breakdown
- **Users by Platform** (Android, iOS, Web)
- **Most Active Platform**
- **Platform-specific Engagement**

---

## 🎯 Setting Up Alerts

### Create Alerts for Important Metrics

1. Go to any Insight
2. Click **"Set Alert"**
3. Configure:
   - **Metric drops below**: X users per day (DAU alert)
   - **Metric increases above**: Y signups per day
   - **Send alert to**: Your email or Slack

Example Alerts:
- Alert when DAU drops below 50 users
- Alert when crash rate exceeds 1%
- Alert when signup rate increases by 50%

---

## 🔐 User Privacy & Data Management

### GDPR Compliance
PostHog provides tools to:
- **Export user data**: Download all data for a specific user
- **Delete user data**: Remove a user and all their events
- **Anonymize events**: Remove personally identifiable information

### Data Retention
Configure in PostHog Settings:
- Event data retention period (default: unlimited)
- Personal data retention (configure based on regulations)

---

## 📱 Testing in Development

To verify tracking is working:

1. **Enable Debug Mode**
   - Already enabled in `app_configs.dart`: `posthogDebug = true`
   - Check console logs for PostHog events

2. **Use PostHog Live Events**
   - Go to PostHog → "Live Events"
   - Perform actions in your app
   - See events appear in real-time

3. **Test User Identification**
   - Sign in with a test account
   - Go to PostHog → "Persons"
   - Search for your test email
   - Verify all properties are set correctly

---

## 🚀 Best Practices

### 1. **Track What Matters**
- Focus on metrics that drive decisions
- Don't over-track (avoid tracking every tiny action)
- Balance detail with performance

### 2. **Use Consistent Naming**
- Event names: `category_action` (e.g., `hymn_viewed`, `audio_played`)
- Property names: snake_case (e.g., `hymn_number`, `auth_provider`)

### 3. **Set Up Regular Reviews**
- Weekly: Check DAU, MAU, and engagement trends
- Monthly: Analyze retention and conversion funnels
- Quarterly: Review and optimize tracking strategy

### 4. **Segment Your Users**
- By platform (Android vs iOS vs Web)
- By authentication method
- By engagement level (power users vs casual users)
- By location/locale

### 5. **Test in Development**
- Always verify tracking before releasing
- Use separate PostHog projects for dev/staging/production
- Monitor for tracking errors in production

---

## 📞 Getting Help

### PostHog Resources
- **Documentation**: [https://posthog.com/docs](https://posthog.com/docs)
- **Community**: [https://posthog.com/community](https://posthog.com/community)
- **Support**: [https://posthog.com/support](https://posthog.com/support)

### Your PostHog Instance
- **Dashboard**: [https://us.i.posthog.com](https://us.i.posthog.com)
- **API Key**: `phc_QDMI8BXsq8vFdtUfyogL4AWCZSkPPjT93idVFiKXSTT`
- **Project**: Hymnes SDA FR

---

## ✅ Quick Checklist

- [ ] PostHog is initialized on app start
- [ ] User identification happens on login/signup
- [ ] Anonymous users are tracked before login
- [ ] All auth methods track user properties (email, google, apple)
- [ ] Device properties are included in all events
- [ ] DAU dashboard is set up in PostHog
- [ ] Alerts are configured for key metrics
- [ ] Team has access to PostHog dashboard
- [ ] Privacy policy mentions analytics tracking
- [ ] User data can be exported/deleted on request

---

## 🔄 Recent Changes

### What We Added:
1. ✅ **Comprehensive User Identification**
   - Device properties (platform, OS, app version)
   - User properties (email, name, phone, photo, auth provider)
   - Automatic session tracking for DAU

2. ✅ **Enhanced Event Tracking**
   - All events include user context
   - Automatic device properties in every event
   - Dynamic app version tracking

3. ✅ **Multiple Auth Provider Tracking**
   - Email sign-in tracking
   - Google sign-in tracking
   - Apple sign-in tracking
   - Sign-up tracking with user details

4. ✅ **Anonymous User Tracking**
   - Track users before they log in
   - Helps calculate total DAU (logged in + anonymous)

5. ✅ **Profile Update Tracking**
   - Track when users update their profile
   - Update user properties in PostHog

---

## 🎉 You're All Set!

Your app now has comprehensive user tracking. Head over to PostHog to start analyzing your users and watching those Daily Active User numbers grow! 🚀

