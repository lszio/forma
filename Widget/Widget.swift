import WidgetKit
import SwiftUI
import SwiftData

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), activeSpaces: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), activeSpaces: [])
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // In a real app, this would fetch from SwiftData shared container
        let entry = SimpleEntry(date: Date(), activeSpaces: [])
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let activeSpaces: [SpaceInfo]
}

struct SpaceInfo: Identifiable {
    let id: UUID
    let name: String
    let icon: String
}

struct WidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Intents")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            
            if entry.activeSpaces.isEmpty {
                Text("No active intents")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            } else {
                ForEach(entry.activeSpaces.prefix(3)) { space in
                    HStack {
                        Image(systemName: space.icon)
                        Text(space.name)
                            .font(.caption.bold())
                    }
                }
            }
            Spacer()
        }
    }
}

struct formaWidget: Widget {
    let kind: String = "Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Active Intents")
        .description("Quick access to your current context-aware spaces.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
