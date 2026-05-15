import WidgetKit
import SwiftUI
import SwiftData

struct Provider: AppIntentTimelineProvider {
    typealias Entry = SimpleEntry
    typealias Intent = SelectSpaceIntent

    func placeholder(in context: TimelineProviderContext) -> SimpleEntry {
        SimpleEntry(date: Date(), space: nil)
    }

    func snapshot(for configuration: SelectSpaceIntent, in context: TimelineProviderContext) async -> SimpleEntry {
        let space = await fetchSpace(for: configuration.space?.id)
        return SimpleEntry(date: Date(), space: space)
    }

    func timeline(for configuration: SelectSpaceIntent, in context: TimelineProviderContext) async -> Timeline<SimpleEntry> {
        let space = await fetchSpace(for: configuration.space?.id)
        let entry = SimpleEntry(date: Date(), space: space)
        return Timeline(entries: [entry], policy: .atEnd)
    }
    
    @MainActor
    private func fetchSpace(for id: UUID?) async -> Space? {
        guard let id = id else { return nil }
        do {
            let modelContainer = try ModelContainer(for: Space.self)
            let descriptor = FetchDescriptor<Space>(predicate: #Predicate { $0.id == id })
            let spaces = try modelContainer.mainContext.fetch(descriptor)
            return spaces.first
        } catch {
            return nil
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let space: Space?
}

struct WidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let space = entry.space {
                HStack {
                    Image(systemName: space.icon)
                        .font(.headline)
                        .foregroundStyle(Color.accentColor)
                    Text(space.name)
                        .font(.headline)
                }
                
                let actions = space.actions
                if actions.isEmpty {
                    Text("No apps in this space")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(actions.prefix(3), id: \.self) { action in
                            if case .openApp(let appId, let scheme) = action {
                                HStack {
                                    Image(systemName: "app")
                                        .font(.caption)
                                    Text(appId.bundleId.split(separator: ".").last?.capitalized ?? appId.bundleId)
                                        .font(.caption)
                                }
                            }
                        }
                        if actions.count > 3 {
                            Text("+ \(actions.count - 3) more")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } else {
                Text("Edit widget to select a space")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }
}

struct formaWidget: Widget {
    let kind: String = "Widget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectSpaceIntent.self, provider: Provider()) { entry in
            WidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Space Shortcut")
        .description("Quick access to a specific space.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
