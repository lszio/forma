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
        let space = await fetchTargetSpace(for: configuration)
        return SimpleEntry(date: Date(), space: space)
    }

    func timeline(for configuration: SelectSpaceIntent, in context: TimelineProviderContext) async -> Timeline<SimpleEntry> {
        let space = await fetchTargetSpace(for: configuration)
        let entry = SimpleEntry(date: Date(), space: space)
        return Timeline(entries: [entry], policy: .atEnd)
    }
    
    @MainActor
    private func fetchTargetSpace(for configuration: SelectSpaceIntent) async -> Space? {
        do {
            let modelContainer = try ModelContainer(for: Space.self)
            
            // 1. Specifically selected space
            if let selectedId = configuration.space?.id {
                let descriptor = FetchDescriptor<Space>(predicate: #Predicate { $0.id == selectedId })
                return try modelContainer.mainContext.fetch(descriptor).first
            }
            
            // 2. Default: All Apps or first available
            let allSpaces = try modelContainer.mainContext.fetch(FetchDescriptor<Space>())
            return allSpaces.first { $0.name == "Dashboard" } ?? allSpaces.first
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
    @Environment(\.widgetFamily) var family

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let space = entry.space {
                // Style: Siri Suggestions style grid
                let appIds = space.appIds
                let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)
                
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(0..<maxDisplayCount, id: \.self) { index in
                        if index < appIds.count {
                            let appId = appIds[index]
                            AppIconWithLabel(appId: appId)
                        } else {
                            // Empty placeholder to maintain grid
                            Color.clear.frame(height: 50)
                        }
                    }
                }
            } else {
                ContentUnavailableView("No Space", systemImage: "square.grid.2x2")
            }
        }
    }
    
    private var maxDisplayCount: Int {
        switch family {
        case .systemSmall: return 4
        case .systemMedium: return 8
        default: return 8
        }
    }
}

struct AppIconWithLabel: View {
    let appId: String
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                // Native Icon lookalike
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .fill(LinearGradient(colors: [.white, Color(.systemGray6)], startPoint: .top, endPoint: .bottom))
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                
                if let app = AppRegistry.shared.get(id: appId) {
                    Image(systemName: app.icon)
                        .font(.system(size: 24))
                        .foregroundStyle(Color.accentColor)
                } else {
                    Image(systemName: "app.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.gray)
                }
            }
            .frame(width: 48, height: 48)
            
            if let app = AppRegistry.shared.get(id: appId) {
                Text(app.name)
                    .font(.system(size: 10, weight: .medium))
                    .lineLimit(1)
            }
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
        .configurationDisplayName("Space View")
        .description("Display apps from your chosen space.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
