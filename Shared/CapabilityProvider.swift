import Foundation
import SwiftData

@Model
final class CapabilityProvider: Identifiable {
    @Attribute(.unique) var id: String // e.g., bundleId "com.apple.Music"
    var name: String
    var icon: String
    var scheme: String
    var supportedCapabilitiesData: Data
    
    @Transient
    var supportedCapabilities: [String] {
        get { (try? JSONDecoder().decode([String].self, from: supportedCapabilitiesData)) ?? [] }
        set { supportedCapabilitiesData = (try? JSONEncoder().encode(newValue)) ?? Data() }
    }
    
    init(id: String, name: String, icon: String, scheme: String, supportedCapabilities: [String] = []) {
        self.id = id
        self.name = name
        self.icon = icon
        self.scheme = scheme
        self.supportedCapabilitiesData = (try? JSONEncoder().encode(supportedCapabilities)) ?? Data()
    }
}
