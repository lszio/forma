import Foundation

struct Context: Codable, Hashable {
    let time: Date
    let currentFocusMode: String?
    let connectedDevices: [String] // e.g., Bluetooth device identifiers or Wi-Fi SSIDs
    
    // Additional properties for advanced matching
    let weekday: Int
    let batteryLevel: Float
    let lowPowerMode: Bool
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
