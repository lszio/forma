import Foundation

struct Context: Codable, Hashable {
    let now: Date
    let weekday: Int
    let batteryLevel: Float
    let lowPowerMode: Bool
    let focusMode: String?
    let recentUsage: [String: TimeInterval]
    let appUsageFrequency: [String: Int]
    let deviceState: DeviceState
}

struct DeviceState: Codable, Hashable {
    let isCharging: Bool
    let screenBrightness: Float
    let thermalState: ThermalState
    let networkType: NetworkType

    enum ThermalState: Int, Codable, Hashable {
        case nominal, fair, serious, critical
    }

    enum NetworkType: String, Codable, Hashable {
        case wifi, cellular, none
    }
}

