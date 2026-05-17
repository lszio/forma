import Foundation
import SwiftData

@Model
final class Contribution: Identifiable {
    @Attribute(.unique) var id: UUID
    var targetCapability: String
    var weight: Double
    var reason: String
    var requiredContextIdsData: Data
    
    @Transient
    var requiredContextIds: [String] {
        get { (try? JSONDecoder().decode([String].self, from: requiredContextIdsData)) ?? [] }
        set { requiredContextIdsData = (try? JSONEncoder().encode(newValue)) ?? Data() }
    }
    
    init(id: UUID = UUID(), targetCapability: String, weight: Double, reason: String, requiredContextIds: [String]) {
        self.id = id
        self.targetCapability = targetCapability
        self.weight = weight
        self.reason = reason
        self.requiredContextIdsData = (try? JSONEncoder().encode(requiredContextIds)) ?? Data()
    }
}
