import AppIntents
import SwiftData

struct SelectSpaceIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Space"
    static var description = IntentDescription("Select a space to display in the widget.")

    @Parameter(title: "Space")
    var space: SpaceEntity?
}

struct SpaceEntity: AppEntity {
    let id: UUID
    let name: String
    let icon: String

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Space"
    static var defaultQuery = SpaceQuery()

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)", image: .init(systemName: icon))
    }
}

struct SpaceQuery: EntityQuery {
    func entities(for identifiers: [UUID]) async throws -> [SpaceEntity] {
        let modelContainer = try ModelContainer(for: Space.self)
        let descriptor = FetchDescriptor<Space>(predicate: #Predicate { identifiers.contains($0.id) })
        let spaces = try await modelContainer.mainContext.fetch(descriptor)
        return spaces.map { SpaceEntity(id: $0.id, name: $0.name, icon: $0.icon) }
    }

    func suggestedEntities() async throws -> [SpaceEntity] {
        let modelContainer = try ModelContainer(for: Space.self)
        let descriptor = FetchDescriptor<Space>()
        let spaces = try await modelContainer.mainContext.fetch(descriptor)
        return spaces.map { SpaceEntity(id: $0.id, name: $0.name, icon: $0.icon) }
    }
}
