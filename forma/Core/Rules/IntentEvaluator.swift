import Foundation

// SICP: Abstraction through Higher-Order Functions
// We define a generic Evaluator that decouples the rule structure from the evaluation logic.

struct IntentEvaluator {
    let context: Context
    
    func evaluate(_ node: RuleNode) -> Bool {
        switch node {
        case .and(let nodes):
            return nodes.allSatisfy { evaluate($0) }
        case .or(let nodes):
            return nodes.contains { evaluate($0) }
        case .not(let node):
            return !evaluate(node)
        case .time(let rule):
            return checkTime(rule)
        case .battery(let rule):
            return checkBattery(rule)
        case .focus(let rule):
            return context.focusMode == rule.name
        }
    }
    
    private func checkTime(_ rule: TimeRule) -> Bool {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: context.now)
        let weekday = calendar.component(.weekday, from: context.now)
        
        let isWithinTime = rule.startHour <= rule.endHour ? 
            (hour >= rule.startHour && hour < rule.endHour) :
            (hour >= rule.startHour || hour < rule.endHour)
        
        return isWithinTime && rule.weekdays.contains(weekday)
    }
    
    private func checkBattery(_ rule: BatteryRule) -> Bool {
        let isChargingMatch = rule.isCharging == nil || rule.isCharging == context.deviceState.isCharging
        return context.batteryLevel >= rule.minLevel && 
               context.batteryLevel <= rule.maxLevel && 
               isChargingMatch
    }
}
