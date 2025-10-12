//
//  HymnesHomeWidgetLiveActivity.swift
//  HymnesHomeWidget
//
//  Created by Yaovi Emmanuel Josué Djossou on 10/11/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct HymnesHomeWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct HymnesHomeWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: HymnesHomeWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension HymnesHomeWidgetAttributes {
    fileprivate static var preview: HymnesHomeWidgetAttributes {
        HymnesHomeWidgetAttributes(name: "World")
    }
}

extension HymnesHomeWidgetAttributes.ContentState {
    fileprivate static var smiley: HymnesHomeWidgetAttributes.ContentState {
        HymnesHomeWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: HymnesHomeWidgetAttributes.ContentState {
         HymnesHomeWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: HymnesHomeWidgetAttributes.preview) {
   HymnesHomeWidgetLiveActivity()
} contentStates: {
    HymnesHomeWidgetAttributes.ContentState.smiley
    HymnesHomeWidgetAttributes.ContentState.starEyes
}
