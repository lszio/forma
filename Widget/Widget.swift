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
            
            // If user has specifically selected a space in widget settings
            if let selectedId = configuration.space?.id {
                let descriptor = FetchDescriptor<Space>(predicate: #Predicate { $0.id == selectedId })
                return try modelContainer.mainContext.fetch(descriptor).first
            }
            
            // DEFAULT logic: Dynamic Intent
            // In a full implementation, we would build a Context here and run the Rule Engine.
            // For now, we take the most 'recently active' or first space as the 'Dynamic Intent'.
            let allSpaces = try modelContainer.mainContext.fetch(FetchDescriptor<Space>())
            
            // Simulate Intent: Find space that matches current time rule or has most weight
            // Returning the first one for now as the "Inferred Intent"
            return allSpaces.first
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
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text(space.name)
                            .font(.subheadline.bold())
                        if !space.tags.isEmpty {
                            Text(space.tags.joined(separator: " • "))
                                .font(.system(size: 8))
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                }
                
                // For Widget, we use the Space's own app order + learning
                let targetApps = Array(Set(space.orderedAppIds + space.rules.flatMap { $0.targetApps.map { $0.bundleId } } + space.learningWeights.keys))
                    .prefix(4)
                    .map { AppID(bundleId: $0) }
                
                if targetApps.isEmpty {
                    Text("No apps predicted")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    HStack(spacing: 12) {
                        ForEach(targetApps) { appID in
                            VStack(spacing: 4) {
                                // NATIVE ICON SIMULATION
                                NativeIconView(appID: appID)
                                Text(appID.bundleId.split(separator: ".").last?.capitalized ?? "App")
                                    .font(.system(size: 10))
                                    .lineLimit(1)
                            }
                        }
                    }
                }
            } else {
                Text("No matching Space found")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct NativeIconView: View {
    let appID: AppID
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(LinearGradient(gradient: Gradient(colors: [.white, Color(.systemGray6)]), startPoint: .top, endPoint: .bottom))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
            
            // Map known bundle IDs to SF Symbols that represent the "Native" look
            Image(systemName: symbolForBundleId(appID.bundleId))
                .foregroundStyle(colorForBundleId(appID.bundleId))
                .font(.title3)
        }
        .frame(width: 44, height: 44)
    }
    
    private func symbolForBundleId(_ id: String) -> String {
        switch id {
        case "com.apple.Music": return "music.note"
        case "com.apple.mail": return "envelope.fill"
        case "com.apple.mobilesafari": return "safari.fill"
        case "com.apple.calendar": return "calendar"
        case "com.apple.Preferences": return "gearshape.fill"
        case "com.spotify.client": return "waveform"
        case "com.tinyspeck.chatlyio": return "bubble.left.and.bubble.right.fill"
        default: return "app.fill"
        }
    }
    
    private func colorForBundleId(_ id: String) -> Color {
        switch id {
        case "com.apple.Music": return .pink
        case "com.apple.mail": return .blue
        case "com.apple.mobilesafari": return .blue
        case "com.apple.calendar": return .red
        case "com.apple.Preferences": return .gray
        case "com.spotify.client": return .green
        case "com.tinyspeck.chatlyio": return .purple
        default: return .accentColor
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
        .configurationDisplayName("Smart Intent")
        .description("Shows the space matching your current intent.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
