import Foundation
import SwiftData

@Model
final class Space: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var icon: String
    var isDynamic: Bool
    var rulesData: Data
    var learningWeightsData: Data

    @Transient
    var rules: [Rule] {
        get {
            (try? JSONDecoder().decode([Rule].self, from: rulesData)) ?? []
        }
        set {
            rulesData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }
    
    @Transient
    var learningWeights: [String: Float] {
        get {
            (try? JSONDecoder().decode([String: Float].self, from: learningWeightsData)) ?? [:]
        }
        set {
            learningWeightsData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }

    init(id: UUID = UUID(), 
         name: String, 
         icon: String, 
         isDynamic: Bool = true,
         rules: [Rule] = [],
         learningWeights: [String: Float] = [:]) {
        self.id = id
        self.name = name
        self.icon = icon
        self.isDynamic = isDynamic
        
        self.rulesData = (try? JSONEncoder().encode(rules)) ?? Data()
        self.learningWeightsData = (try? JSONEncoder().encode(learningWeights)) ?? Data()
    }
}
