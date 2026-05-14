import Foundation
import SwiftData

@Model
final class DiscoveredApp: Identifiable {
    @Attribute(.unique) var id: String // bundleId or customId
    var name: String
    var icon: String
    var scheme: String
    var category: String
    var lastVerified: Date
    
    init(id: String, name: String, icon: String, scheme: String, category: String = "Custom") {
        self.id = id
        self.name = name
        self.icon = icon
        self.scheme = scheme
        self.category = category
        self.lastVerified = Date()
    }
}
