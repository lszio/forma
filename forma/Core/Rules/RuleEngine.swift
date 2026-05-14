import Foundation

struct RuleEngine {
    func resolve(spaces: [Space], context: Context) -> [Space] {
        let evaluator = IntentEvaluator(context: context)
        return spaces.filter { space in
            guard let rule = space.ruleTree else {
                return true
            }
            return evaluator.evaluate(rule)
        }
    }
}
