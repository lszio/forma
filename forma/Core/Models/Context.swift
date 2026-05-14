import Foundation

struct Context {
    let now: Date
    let weekday: Int
    let batteryLevel: Float
    let lowPowerMode: Bool
    let focusMode: String?
    let recentUsage: [AppID: Date]
    let appUsageFrequency: [AppID: Int]
    let deviceState: DeviceState
}

struct DeviceState {
    let isCharging: Bool
    let screenBrightness: Float
    let thermalState: ThermalState
    let networkType: NetworkType
}

enum ThermalState: Int, Codable {
    case nominal, fair, serious, critical
}

enum NetworkType: String, Codable {
    case wifi, cellular, none
}
