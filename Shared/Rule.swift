import Foundation

/// Defines a condition that can be evaluated against the current Context
protocol Trigger {
    func evaluate(with context: Context) -> Bool
}

/// Represents a deterministic user-defined rule
struct Rule: Identifiable, Codable, Hashable {
    let id: UUID
    let triggerNode: RuleNode
    let targetApps: [AppID]
    let priority: Int
    
    init(id: UUID = UUID(), triggerNode: RuleNode, targetApps: [AppID], priority: Int) {
        self.id = id
        self.triggerNode = triggerNode
        self.targetApps = targetApps
        self.priority = priority
    }
    
    func evaluate(with context: Context) -> Bool {
        return triggerNode.evaluate(with: context)
    }
}
