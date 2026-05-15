import Foundation

protocol Rule {
    func evaluate(context: Context) -> Bool
}

indirect enum RuleNode: Codable, Hashable {
    case and([RuleNode])
    case or([RuleNode])
    case not(RuleNode)
    case time(TimeRule)
    case battery(BatteryRule)
    case focus(FocusModeRule)
    // case usage(UsageRule) // To be implemented
}

struct TimeRule: Codable, Hashable {
    let startHour: Int
    let endHour: Int
    let weekdays: [Int] // 1 (Sunday) to 7 (Saturday)
}

struct BatteryRule: Codable, Hashable {
    let minLevel: Float
    let maxLevel: Float
    let isCharging: Bool?
}

struct FocusModeRule: Codable, Hashable {
    let name: String
}
