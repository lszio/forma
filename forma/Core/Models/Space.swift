import Foundation
import SwiftData

@Model
final class Space: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var icon: String
    var actionsData: Data
    var ruleTreeData: Data?
    var presentation: PresentationStyle
    var customization: SpaceCustomization

    @Transient
    var actions: [ActionNode] {
        get {
            (try? JSONDecoder().decode([ActionNode].self, from: actionsData)) ?? []
        }
        set {
            actionsData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }

    @Transient
    var ruleTree: RuleNode? {
        get {
            guard let data = ruleTreeData else { return nil }
            return try? JSONDecoder().decode(RuleNode.self, from: data)
        }
        set {
            ruleTreeData = try? JSONEncoder().encode(newValue)
        }
    }

    init(id: UUID = UUID(), 
         name: String, 
         icon: String, 
         actions: [ActionNode] = [], 
         ruleTree: RuleNode? = nil, 
         presentation: PresentationStyle = .appGrid, 
         customization: SpaceCustomization = SpaceCustomization()) {
        self.id = id
        self.name = name
        self.icon = icon
        self.presentation = presentation
        self.customization = customization
        
        // Initialize data properties
        self.actionsData = (try? JSONEncoder().encode(actions)) ?? Data()
        self.ruleTreeData = try? JSONEncoder().encode(ruleTree)
    }
}

enum PresentationStyle: String, Codable {
    case appGrid
    case widgetCompact
    case widgetExpanded
    case stack
    case focus
}

struct SpaceCustomization: Codable {
    var accentColor: String = "Blue"
    var iconStyle: String = "Default"
    var layoutStyle: String = "Grid"
    var animationStyle: String = "Default"
    var rankingMode: String = "Frequency"
}
