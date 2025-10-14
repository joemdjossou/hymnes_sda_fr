package com.joemdjossou.hymnes

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import androidx.core.content.ContextCompat

/**
 * Implementation of App Widget functionality for Hymnes app.
 * Displays hymns count, favorites count, and quick access to main features.
 */
class HymnesHomeWidget : AppWidgetProvider() {
    
    companion object {
        private const val PREFS_NAME = "hymnes_widget_prefs"
        private const val PREF_HYMNS_COUNT = "hymns_count"
        private const val PREF_FAVORITES_COUNT = "favorites_count"
        private const val PREF_FEATURED_HYMN_NUMBER = "featured_hymn_number"
        private const val PREF_FEATURED_HYMN_TITLE = "featured_hymn_title"
        private const val PREF_FEATURED_HYMN_LYRICS = "featured_hymn_lyrics"
        
        // HomeWidget package uses these keys
        private const val HOME_WIDGET_PREFS = "FlutterSharedPreferences"
        private const val HOME_WIDGET_PREFIX = "flutter."
        
        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            // Try to get data from Flutter's SharedPreferences first
            val homeWidgetPrefs = context.getSharedPreferences(HOME_WIDGET_PREFS, Context.MODE_PRIVATE)
            val fallbackPrefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            
            // Get hymns count from Flutter SharedPreferences
            val hymnsCount = homeWidgetPrefs.getInt("$HOME_WIDGET_PREFIX$PREF_HYMNS_COUNT", 
                fallbackPrefs.getInt(PREF_HYMNS_COUNT, 0))
            
            // Get favorites count from Flutter SharedPreferences
            val favoritesCount = homeWidgetPrefs.getInt("$HOME_WIDGET_PREFIX$PREF_FAVORITES_COUNT", 
                fallbackPrefs.getInt(PREF_FAVORITES_COUNT, 0))
            
            // Get featured hymn data from Flutter SharedPreferences
            val featuredHymnNumber = homeWidgetPrefs.getString("$HOME_WIDGET_PREFIX$PREF_FEATURED_HYMN_NUMBER", 
                fallbackPrefs.getString(PREF_FEATURED_HYMN_NUMBER, null))
            val featuredHymnTitle = homeWidgetPrefs.getString("$HOME_WIDGET_PREFIX$PREF_FEATURED_HYMN_TITLE", 
                fallbackPrefs.getString(PREF_FEATURED_HYMN_TITLE, null))
            val featuredHymnLyrics = homeWidgetPrefs.getString("$HOME_WIDGET_PREFIX$PREF_FEATURED_HYMN_LYRICS", 
                fallbackPrefs.getString(PREF_FEATURED_HYMN_LYRICS, null))
            
            // Create RemoteViews for different widget sizes
            val views = createWidgetViews(context, hymnsCount, favoritesCount, featuredHymnNumber, featuredHymnTitle, featuredHymnLyrics)
            
            // Instruct the widget manager to update the widget
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
        
        private fun createWidgetViews(
            context: Context,
            hymnsCount: Int,
            favoritesCount: Int,
            featuredHymnNumber: String?,
            featuredHymnTitle: String?,
            featuredHymnLyrics: String?
        ): RemoteViews {
            val views = RemoteViews(context.packageName, R.layout.hymnes_home_widget)
            
            // Set up click intents
            setupClickIntents(context, views)
            
            // Update text content
            views.setTextViewText(R.id.hymns_count, hymnsCount.toString())
            views.setTextViewText(R.id.favorites_count, favoritesCount.toString())
            
            // Set up featured hymn
            setupFeaturedHymn(views, featuredHymnNumber, featuredHymnTitle, featuredHymnLyrics)
            
            // Set up stats cards
            setupStatsCards(views, hymnsCount, favoritesCount)
            
            return views
        }
        
        private fun setupClickIntents(context: Context, views: RemoteViews) {
            // Main app intent
            val mainIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val mainPendingIntent = PendingIntent.getActivity(
                context, 0, mainIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_container, mainPendingIntent)
            
            // Search intent
            val searchIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                putExtra("action", "search")
            }
            val searchPendingIntent = PendingIntent.getActivity(
                context, 1, searchIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.search_button, searchPendingIntent)
            
            // Favorites intent
            val favoritesIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                putExtra("action", "favorites")
            }
            val favoritesPendingIntent = PendingIntent.getActivity(
                context, 2, favoritesIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.favorites_button, favoritesPendingIntent)
        }
        
        private fun setupFeaturedHymn(
            views: RemoteViews,
            featuredHymnNumber: String?,
            featuredHymnTitle: String?,
            featuredHymnLyrics: String?
        ) {
            if (featuredHymnNumber != null && featuredHymnTitle != null && featuredHymnLyrics != null) {
                views.setTextViewText(R.id.featured_hymn_number, "#$featuredHymnNumber")
                views.setTextViewText(R.id.featured_hymn_title, featuredHymnTitle)
                views.setTextViewText(R.id.featured_hymn_lyrics, featuredHymnLyrics)
                views.setViewVisibility(R.id.featured_hymn_section, android.view.View.VISIBLE)
            } else {
                views.setViewVisibility(R.id.featured_hymn_section, android.view.View.GONE)
            }
        }
        
        private fun setupStatsCards(views: RemoteViews, hymnsCount: Int, favoritesCount: Int) {
            // Set hymns count
            views.setTextViewText(R.id.hymns_count, hymnsCount.toString())
            
            // Set favorites count
            views.setTextViewText(R.id.favorites_count, favoritesCount.toString())
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        // There may be multiple widgets active, so update all of them
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        // Enter relevant functionality for when the first widget is created
    }

    override fun onDisabled(context: Context) {
        // Enter relevant functionality for when the last widget is disabled
    }
    
    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        
        // Handle data updates from the main app
        if (intent.action == "com.joemdjossou.hymnes.UPDATE_WIDGET") {
            val hymnsCount = intent.getIntExtra("hymns_count", 0)
            val favoritesCount = intent.getIntExtra("favorites_count", 0)
            val featuredHymnNumber = intent.getStringExtra("featured_hymn_number")
            val featuredHymnTitle = intent.getStringExtra("featured_hymn_title")
            val featuredHymnLyrics = intent.getStringExtra("featured_hymn_lyrics")
            
            // Save to shared preferences
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            prefs.edit()
                .putInt(PREF_HYMNS_COUNT, hymnsCount)
                .putInt(PREF_FAVORITES_COUNT, favoritesCount)
                .putString(PREF_FEATURED_HYMN_NUMBER, featuredHymnNumber)
                .putString(PREF_FEATURED_HYMN_TITLE, featuredHymnTitle)
                .putString(PREF_FEATURED_HYMN_LYRICS, featuredHymnLyrics)
                .apply()
            
            // Update all widgets
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(
                android.content.ComponentName(context, HymnesHomeWidget::class.java)
            )
            onUpdate(context, appWidgetManager, appWidgetIds)
        }
    }
}