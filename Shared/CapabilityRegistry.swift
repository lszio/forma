import Foundation

struct CapabilityRegistry: Sendable {
    static let shared = CapabilityRegistry()
    
    let capabilities: [Capability] = [
        Capability(id: "media.play.focus", category: "media", displayName: "Play Focus Music", iconName: "headphones"),
        Capability(id: "document.resume", category: "productivity", displayName: "Resume Document", iconName: "doc.text.fill"),
        Capability(id: "task.continue", category: "productivity", displayName: "Continue Tasks", iconName: "checkmark.circle.fill"),
        Capability(id: "communication.reply", category: "communication", displayName: "Reply Messages", iconName: "bubble.left.and.bubble.right.fill"),
        Capability(id: "system.search", category: "system", displayName: "Search", iconName: "magnifyingglass")
    ]
    
    func get(id: String) -> Capability? {
        capabilities.first { $0.id == id }
    }
}
