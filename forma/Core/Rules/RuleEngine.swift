import Foundation

struct RuleEngine {
    func resolve(spaces: [Space], context: Context) -> [Space] {
        return spaces.filter { space in
            // If the space has no rules, we might consider it always active or never active.
            // Let's assume a space with no rules relies on dynamic learning, but for pure rule engine:
            if space.rules.isEmpty { return true }
            
            // A space is active if ANY of its rules evaluate to true
            return space.rules.contains { rule in
                rule.evaluate(with: context)
            }
        }
    }
}
