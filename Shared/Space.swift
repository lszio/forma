import Foundation
import SwiftData

@Model
final class Space: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var icon: String
    var tags: [String]?
    var isEnabled: Bool?
    var actionsData: Data
    var ruleTreeData: Data?
    var presentation: PresentationStyle
    var customization: SpaceCustomization
    var rankingRule: RankingRule?
    var pinnedAppIDs: [String]?

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

    @Transient
    var safeTags: [String] {
        tags ?? []
    }

    @Transient
    var safeIsEnabled: Bool {
        isEnabled ?? true
    }

    @Transient
    var safeRankingRule: RankingRule {
        rankingRule ?? .frequency
    }

    init(id: UUID = UUID(), 
         name: String, 
         icon: String, 
         tags: [String] = [],
         isEnabled: Bool = true,
         actions: [ActionNode] = [], 
         ruleTree: RuleNode? = nil, 
         presentation: PresentationStyle = .appGrid, 
         customization: SpaceCustomization = SpaceCustomization(),
         rankingRule: RankingRule = .frequency,
         pinnedAppIDs: [String] = []) {
        self.id = id
        self.name = name
        self.icon = icon
        self.tags = tags
        self.isEnabled = isEnabled
        self.presentation = presentation
        self.customization = customization
        self.rankingRule = rankingRule
        self.pinnedAppIDs = pinnedAppIDs
        
        // Initialize data properties
        self.actionsData = (try? JSONEncoder().encode(actions)) ?? Data()
        self.ruleTreeData = try? JSONEncoder().encode(ruleTree)
    }
}

enum RankingRule: String, Codable, CaseIterable {
    case frequency = "Frequency"
    case recency = "Recency"
    case alphabetical = "Alphabetical"
    case manual = "Manual"
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
}
