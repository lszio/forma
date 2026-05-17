import Foundation

struct Capability: Identifiable, Hashable, Codable, Sendable {
    let id: String
    let category: String
    let displayName: String
    let iconName: String
}
