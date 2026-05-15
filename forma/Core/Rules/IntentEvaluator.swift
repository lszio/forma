import Foundation

struct IntentEvaluator {
    let context: Context
    
    func evaluate(_ node: RuleNode) -> Bool {
        return node.evaluate(with: context)
    }
}
