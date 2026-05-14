import Foundation

protocol Rule {
    func evaluate(context: Context) -> Bool
}

indirect enum RuleNode: Codable {
    case and([RuleNode])
    case or([RuleNode])
    case not(RuleNode)
    case time(TimeRule)
    case battery(BatteryRule)
    case focus(FocusModeRule)
    // case usage(UsageRule) // To be implemented
}

struct TimeRule: Codable {
    let startHour: Int
    let endHour: Int
    let weekdays: [Int] // 1 (Sunday) to 7 (Saturday)
}

struct BatteryRule: Codable {
    let minLevel: Float
    let maxLevel: Float
    let isCharging: Bool?
}

struct FocusModeRule: Codable {
    let name: String
}
