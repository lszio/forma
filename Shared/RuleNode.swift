import Foundation

/// Evaluates a node against a context
protocol Evaluatable {
    func evaluate(with context: Context) -> Bool
}

indirect enum RuleNode: Codable, Hashable, Evaluatable {
    case and([RuleNode])
    case or([RuleNode])
    case not(RuleNode)
    case time(TimeRule)
    case battery(BatteryRule)
    case focus(FocusModeRule)
    case device(ConnectedDeviceRule)

    func evaluate(with context: Context) -> Bool {
        switch self {
        case .and(let nodes):
            return nodes.allSatisfy { $0.evaluate(with: context) }
        case .or(let nodes):
            return nodes.contains { $0.evaluate(with: context) }
        case .not(let node):
            return !node.evaluate(with: context)
        case .time(let rule):
            return rule.evaluate(with: context)
        case .battery(let rule):
            return rule.evaluate(with: context)
        case .focus(let rule):
            return rule.evaluate(with: context)
        case .device(let rule):
            return rule.evaluate(with: context)
        }
    }
}

struct TimeRule: Codable, Hashable, Evaluatable {
    let startHour: Int
    let endHour: Int
    let weekdays: [Int] // 1 (Sunday) to 7 (Saturday)

    func evaluate(with context: Context) -> Bool {
        if !weekdays.isEmpty && !weekdays.contains(context.weekday) {
            return false
        }
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: context.time)
        return currentHour >= startHour && currentHour < endHour
    }
}

struct BatteryRule: Codable, Hashable, Evaluatable {
    let minLevel: Float
    let maxLevel: Float
    let isCharging: Bool?

    func evaluate(with context: Context) -> Bool {
        if let charging = isCharging, charging != context.deviceState.isCharging {
            return false
        }
        return context.batteryLevel >= minLevel && context.batteryLevel <= maxLevel
    }
}

struct FocusModeRule: Codable, Hashable, Evaluatable {
    let name: String

    func evaluate(with context: Context) -> Bool {
        return context.currentFocusMode == name
    }
}

struct ConnectedDeviceRule: Codable, Hashable, Evaluatable {
    let deviceIdentifier: String
    
    func evaluate(with context: Context) -> Bool {
        return context.connectedDevices.contains(deviceIdentifier)
    }
}
