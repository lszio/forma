import Foundation
import SwiftData

class LearningEngine {
    static let shared = LearningEngine()
    
    private init() {}
    
    /// Records a user interaction (e.g. launching an app) within a specific space
    func recordInteraction(with appID: AppID, in space: Space) {
        guard space.isDynamic else { return }
        
        var weights = space.learningWeights
        let currentWeight = weights[appID.bundleId] ?? 0.0
        
        // Simple frequency learning: increase weight by 1.0 each time.
        weights[appID.bundleId] = currentWeight + 1.0
        space.learningWeights = weights
    }
    
    /// Applies a time decay to the weights so that recent usage is prioritized
    func decayWeights(in space: Space, factor: Float = 0.95) {
        guard space.isDynamic else { return }
        
        var weights = space.learningWeights
        for (bundleId, weight) in weights {
            weights[bundleId] = weight * factor
            // Remove apps with negligible weights to keep the dictionary small
            if weights[bundleId]! < 0.1 {
                weights.removeValue(forKey: bundleId)
            }
        }
        space.learningWeights = weights
    }
}
