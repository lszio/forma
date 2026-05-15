import Foundation
import Combine
#if os(iOS)
import UIKit
#endif

class ContextManager: ObservableObject {
    @Published var currentContext: Context
    
    private var timer: Timer?
    
    init() {
        // Initial mock context
        self.currentContext = Context(
            time: Date(),
            currentFocusMode: nil,
            connectedDevices: [],
            weekday: Calendar.current.component(.weekday, from: Date()),
            batteryLevel: 0.8,
            lowPowerMode: false,
            deviceState: DeviceState(
                isCharging: false,
                screenBrightness: 0.5,
                thermalState: .nominal,
                networkType: .wifi
            )
        )
        
        startTimer()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.refresh()
        }
    }
    
    func refresh() {
        // In a real app, this would query system APIs
        #if os(iOS)
        UIDevice.current.isBatteryMonitoringEnabled = true
        let batteryLevel = UIDevice.current.batteryLevel
        let isCharging = UIDevice.current.batteryState == .charging || UIDevice.current.batteryState == .full
        #else
        let batteryLevel: Float = 1.0
        let isCharging = true
        #endif
        
        self.currentContext = Context(
            time: Date(),
            currentFocusMode: nil, // Requires specialized APIs or focus intent
            connectedDevices: [],
            weekday: Calendar.current.component(.weekday, from: Date()),
            batteryLevel: batteryLevel,
            lowPowerMode: false, // Could use ProcessInfo.processInfo.isLowPowerModeEnabled
            deviceState: DeviceState(
                isCharging: isCharging,
                screenBrightness: 0.5,
                thermalState: .nominal,
                networkType: .wifi
            )
        )
    }
}
