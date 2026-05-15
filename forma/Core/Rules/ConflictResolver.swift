import Foundation

struct ConflictResolver {
    
    /// Returns the sorted, top apps to display for a given space and context.
    /// It arbitrates between deterministic hard rules and probabilistic learning weights.
    static func resolveApps(for space: Space, context: Context, maxCount: Int = 8) -> [AppID] {
        var appScores: [AppID: Float] = [:]
        
        // 1. Probabilistic Learning Weights (Base scores)
        if space.isDynamic {
            for (bundleId, weight) in space.learningWeights {
                appScores[AppID(bundleId: bundleId)] = weight
            }
        }
        
        // 2. Deterministic Rules (High priority overrides)
        // If a rule matches the context, its target apps get a massive score boost.
        let evaluator = IntentEvaluator(context: context)
        for rule in space.rules {
            if evaluator.evaluate(rule.triggerNode) {
                let boost: Float = 1000.0 * Float(rule.priority)
                for appID in rule.targetApps {
                    appScores[appID] = (appScores[appID] ?? 0.0) + boost
                }
            }
        }
        
        // 3. Sort by score descending and return the top N apps
        let sortedApps = appScores.sorted { $0.value > $1.value }.map { $0.key }
        return Array(sortedApps.prefix(maxCount))
    }
}
