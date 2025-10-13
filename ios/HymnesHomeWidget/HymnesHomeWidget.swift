//
//  HymnesHomeWidget.swift
//  HymnesHomeWidget
//
//  Created by Yaovi Emmanuel Josué Djossou on 10/11/25.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), hymnsCount: 0, favoritesCount: 0, featuredHymn: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), hymnsCount: 0, favoritesCount: 0, featuredHymn: nil)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline with data from shared container
        let currentDate = Date()
        let hymnsCount = getHymnsCount()
        let favoritesCount = getFavoritesCount()
        let featuredHymn = getFeaturedHymn()
        
        let entry = SimpleEntry(date: currentDate, hymnsCount: hymnsCount, favoritesCount: favoritesCount, featuredHymn: featuredHymn)
        entries.append(entry)

        // Update every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        let timeline = Timeline(entries: entries, policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func getHymnsCount() -> Int {
        if let sharedDefaults = UserDefaults(suiteName: "group.hymnesHomeWidget") {
            return sharedDefaults.integer(forKey: "hymns_count")
        }
        return 0
    }
    
    private func getFavoritesCount() -> Int {
        if let sharedDefaults = UserDefaults(suiteName: "group.hymnesHomeWidget") {
            return sharedDefaults.integer(forKey: "favorites_count")
        }
        return 0
    }
    
    private func getFeaturedHymn() -> FeaturedHymn? {
        if let sharedDefaults = UserDefaults(suiteName: "group.hymnesHomeWidget") {
            guard let number = sharedDefaults.string(forKey: "featured_hymn_number"),
                  let title = sharedDefaults.string(forKey: "featured_hymn_title"),
                  let lyrics = sharedDefaults.string(forKey: "featured_hymn_lyrics") else {
                return nil
            }
            return FeaturedHymn(number: number, title: title, lyrics: lyrics)
        }
        return nil
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let hymnsCount: Int
    let favoritesCount: Int
    let featuredHymn: FeaturedHymn?
}

struct FeaturedHymn {
    let number: String
    let title: String
    let lyrics: String
}

struct HymnesHomeWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

struct SmallWidgetView: View {
    let entry: SimpleEntry
    @Environment(\.colorScheme) var colorScheme
    
    var primaryTextColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    var secondaryTextColor: Color {
        colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.6)
    }
    
    var accentColor: Color {
        Color(red: 0.13, green: 0.55, blue: 0.13)
    }
    
    var body: some View {
        VStack(spacing: 6) {
            // App icon and title
            HStack {
                Image(systemName: "music.note")
                    .font(.title3)
                    .foregroundColor(accentColor)
                Spacer()
            }
            
            // Featured hymn (if available)
            if let hymn = entry.featuredHymn {
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text("#\(hymn.number)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(accentColor)
                        Spacer()
                    }
                    Text(hymn.title)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(primaryTextColor)
                        .lineLimit(2)
                    Text(hymn.lyrics)
                        .font(.caption2)
                        .foregroundColor(secondaryTextColor)
                        .lineLimit(2)
                }
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                )
            } else {
                Spacer()
            }
            
            Spacer()
            
            // Stats
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "music.note.list")
                        .font(.caption2)
                        .foregroundColor(accentColor)
                    Text("\(entry.hymnsCount)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(primaryTextColor)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                )
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.caption2)
                        .foregroundColor(accentColor)
                    Text("\(entry.favoritesCount)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(primaryTextColor)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                )
            }
        }
        .padding(12)
    }
}

struct MediumWidgetView: View {
    let entry: SimpleEntry
    @Environment(\.colorScheme) var colorScheme
    
    var primaryTextColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    var secondaryTextColor: Color {
        colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.6)
    }
    
    var accentColor: Color {
        Color(red: 0.13, green: 0.55, blue: 0.13)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Image(systemName: "music.note")
                    .font(.title2)
                    .foregroundColor(accentColor)
                Text("Hymnes")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(primaryTextColor)
                Spacer()
            }
            
            // Featured hymn or stats
            if let hymn = entry.featuredHymn {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("#\(hymn.number)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(accentColor)
                        Spacer()
                    }
                    Text(hymn.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(primaryTextColor)
                        .lineLimit(2)
                    Text(hymn.lyrics)
                        .font(.caption)
                        .foregroundColor(secondaryTextColor)
                        .lineLimit(3)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                )
            } else {
                // Stats fallback
                HStack(spacing: 16) {
                    StatCard(
                        icon: "music.note.list",
                        value: "\(entry.hymnsCount)",
                        label: "Hymnes",
                        color: accentColor
                    )
                    
                    StatCard(
                        icon: "heart.fill",
                        value: "\(entry.favoritesCount)",
                        label: "Favoris",
                        color: accentColor
                    )
                }
            }
            
            Spacer()
        }
        .padding(16)
    }
}

struct LargeWidgetView: View {
    let entry: SimpleEntry
    @Environment(\.colorScheme) var colorScheme
    
    var primaryTextColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    var secondaryTextColor: Color {
        colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.6)
    }
    
    var accentColor: Color {
        Color(red: 0.13, green: 0.55, blue: 0.13)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: "music.note")
                    .font(.title)
                    .foregroundColor(accentColor)
                VStack(alignment: .leading) {
                    Text("Hymnes")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(primaryTextColor)
                    Text("French Adventist Hymns")
                        .font(.caption)
                        .foregroundColor(secondaryTextColor)
                }
                Spacer()
            }
            
            // Featured hymn section
            if let hymn = entry.featuredHymn {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Featured Hymn")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(secondaryTextColor)
                        Spacer()
                        Text("#\(hymn.number)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(accentColor)
                    }
                    
                    Text(hymn.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(primaryTextColor)
                        .lineLimit(2)
                    
                    Text(hymn.lyrics)
                        .font(.caption)
                        .foregroundColor(secondaryTextColor)
                        .lineLimit(4)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                )
            }
            
            // Stats grid
            HStack(spacing: 16) {
                StatCard(
                    icon: "music.note.list",
                    value: "\(entry.hymnsCount)",
                    label: "Total Hymns",
                    color: accentColor
                )
                
                StatCard(
                    icon: "heart.fill",
                    value: "\(entry.favoritesCount)",
                    label: "Favorites",
                    color: accentColor
                )
            }
            
            // Quick actions
            HStack(spacing: 12) {
                QuickActionButton(icon: "magnifyingglass", label: "Search")
                QuickActionButton(icon: "heart", label: "Favorites")
                QuickActionButton(icon: "gear", label: "Settings")
            }
            
            Spacer()
        }
        .padding(16)
    }
}

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    @Environment(\.colorScheme) var colorScheme
    
    var primaryTextColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    var secondaryTextColor: Color {
        colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.6)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(primaryTextColor)
            }
            Text(label)
                .font(.caption2)
                .foregroundColor(secondaryTextColor)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
        )
    }
}

struct QuickActionButton: View {
    let icon: String
    let label: String
    @Environment(\.colorScheme) var colorScheme
    
    var iconColor: Color {
        Color(red: 0.13, green: 0.55, blue: 0.13)
    }
    
    var textColor: Color {
        colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.6)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(iconColor)
            Text(label)
                .font(.caption2)
                .foregroundColor(textColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
        )
    }
}

struct HymnesHomeWidget: Widget {
    let kind: String = "HymnesHomeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            HymnesHomeWidgetEntryView(entry: entry)
                .containerBackground(.clear, for: .widget)
        }
        .configurationDisplayName("Hymnes")
        .description("Quick access to your favorite hymns and statistics")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#Preview(as: .systemSmall) {
    HymnesHomeWidget()
} timeline: {
    SimpleEntry(
        date: .now,
        hymnsCount: 150,
        favoritesCount: 12,
        featuredHymn: FeaturedHymn(
            number: "1",
            title: "Vous qui sur la terre !",
            lyrics: "Vous qui sur la terre habitez, Chantez à haute voix, chantez!"
        )
    )
}

#Preview(as: .systemMedium) {
    HymnesHomeWidget()
} timeline: {
    SimpleEntry(
        date: .now,
        hymnsCount: 150,
        favoritesCount: 12,
        featuredHymn: FeaturedHymn(
            number: "1",
            title: "Vous qui sur la terre !",
            lyrics: "Vous qui sur la terre habitez, Chantez à haute voix, chantez! Réjouissez-vous au Seigneur, Par un saint hymne à son honneur!"
        )
    )
}

#Preview(as: .systemLarge) {
    HymnesHomeWidget()
} timeline: {
    SimpleEntry(
        date: .now,
        hymnsCount: 150,
        favoritesCount: 12,
        featuredHymn: FeaturedHymn(
            number: "1",
            title: "Vous qui sur la terre !",
            lyrics: "Vous qui sur la terre habitez, Chantez à haute voix, chantez! Réjouissez-vous au Seigneur, Par un saint hymne à son honneur! N'est-il pas le Dieu souverain Qui nous a formés de sa main?"
        )
    )
}
