import Foundation

struct ConflictResolver {
    
    /// Returns the sorted, top apps to display for a given space and context.
    static func resolveApps(for space: Space, context: Context, maxCount: Int = 8) -> [AppID] {
        // 1. Start with the explicitly ordered apps defined by the user
        var finalAppIds = space.orderedAppIds
        
        // 2. Add apps from active rules if they aren't already present
        let evaluator = IntentEvaluator(context: context)
        for rule in space.rules.sorted(by: { $0.priority > $1.priority }) {
            if evaluator.evaluate(rule.triggerNode) {
                for appID in rule.targetApps {
                    if !finalAppIds.contains(appID.bundleId) {
                        finalAppIds.append(appID.bundleId)
                    }
                }
            }
        }
        
        // 3. Merge with dynamic learning weights if space allows
        if space.isDynamic {
            let learnedAppIds = space.learningWeights.sorted { $0.value > $1.value }.map { $0.key }
            for bundleId in learnedAppIds {
                if !finalAppIds.contains(bundleId) {
                    finalAppIds.append(bundleId)
                }
            }
        }
        
        // Return as AppID objects
        return finalAppIds.prefix(maxCount).map { AppID(bundleId: $0) }
    }
}
