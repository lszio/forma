import Foundation
import SwiftData

@Model
final class Space: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var icon: String
    var tags: [String] = []
    var appIds: [String] = []
    var isAllAppsSpace: Bool = false
    var lastModified: Date = Date()
    
    init(id: UUID = UUID(), name: String, icon: String, tags: [String] = [], appIds: [String] = [], isAllAppsSpace: Bool = false) {
        self.id = id
        self.name = name
        self.icon = icon
        self.tags = tags
        self.appIds = appIds
        self.isAllAppsSpace = isAllAppsSpace
        self.lastModified = Date()
    }
}
