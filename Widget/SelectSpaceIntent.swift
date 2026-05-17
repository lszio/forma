import SwiftUI
import AppIntents
import SwiftData

struct SelectSpaceIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Space"
    static var description = IntentDescription("Pick a space to display in the widget.")

    @Parameter(title: "Space")
    var space: SpaceEntity?

    init() {}
}

struct SpaceEntity: AppEntity {
    let id: UUID
    let name: String

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Space"
    static var defaultQuery = SpaceQuery()

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

struct SpaceQuery: EntityQuery {
    @MainActor
    func entities(for identifiers: [UUID]) async throws -> [SpaceEntity] {
        let container = try ModelContainer(for: Space.self)
        let descriptor = FetchDescriptor<Space>(predicate: #Predicate { identifiers.contains($0.id) })
        let spaces = try container.mainContext.fetch(descriptor)
        return spaces.map { SpaceEntity(id: $0.id, name: $0.name) }
    }

    @MainActor
    func suggestedEntities() async throws -> [SpaceEntity] {
        let container = try ModelContainer(for: Space.self)
        let spaces = try container.mainContext.fetch(FetchDescriptor<Space>())
        return spaces.map { SpaceEntity(id: $0.id, name: $0.name) }
    }
}
