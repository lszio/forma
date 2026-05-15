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
        VStack(alignment: .leading, spacing: 12) {
            if let space = entry.space {
                HStack {
                    Image(systemName: space.icon)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(6)
                        .background(Color.accentColor, in: Circle())
                    Text(space.name)
                        .font(.subheadline.bold())
                    Spacer()
                }
                
                let targetApps = Array(Set(space.rules.flatMap { $0.targetApps } + space.learningWeights.keys.map { AppID(bundleId: $0) }))
                
                if targetApps.isEmpty {
                    Text("No apps predicted")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    HStack(spacing: 12) {
                        ForEach(targetApps.prefix(4)) { appID in
                            VStack(spacing: 4) {
                                Circle()
                                    .fill(Color.secondary.opacity(0.2))
                                    .frame(width: 44, height: 44)
                                    .overlay {
                                        Image(systemName: "app")
                                            .foregroundStyle(Color.accentColor)
                                    }
                                Text(appID.bundleId.split(separator: ".").last?.capitalized ?? "App")
                                    .font(.system(size: 10))
                                    .lineLimit(1)
                            }
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
        .padding(.vertical, 4)
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
