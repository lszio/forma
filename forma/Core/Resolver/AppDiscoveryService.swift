import Foundation
import SwiftUI
import Combine

// SICP: Stream-like processing of app discovery
@MainActor
class AppDiscoveryService: ObservableObject {
    @Published var availableApps: [SystemApp] = []
    @Published var isScanning = false
    
    static let shared = AppDiscoveryService()
    
    private init() {}
    
    func performDiscovery() async {
        isScanning = true
        
        var found: [SystemApp] = []
        
        // 1. Check Library Apps
        for app in SystemApp.library {
            if isAppInstalled(bundleId: app.id, scheme: app.scheme) {
                found.append(app)
            }
        }
        
        // 2. Scan /Applications (macOS only)
        #if os(macOS)
        let localApps = scanApplicationsDirectory()
        for app in localApps {
            if !found.contains(where: { $0.id == app.id }) {
                found.append(app)
            }
        }
        #endif
        
        self.availableApps = found
        isScanning = false
    }
    
    private func isAppInstalled(bundleId: String, scheme: String) -> Bool {
        #if os(iOS)
        if let url = URL(string: scheme), UIApplication.shared.canOpenURL(url) {
            return true
        }
        return false
        #elseif os(macOS)
        return NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) != nil
        #else
        return false
        #endif
    }
    
    #if os(macOS)
    private func scanApplicationsDirectory() -> [SystemApp] {
        let fileManager = FileManager.default
        let appDir = "/Applications"
        var foundApps: [SystemApp] = []
        
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: appDir)
            for item in contents where item.hasSuffix(".app") {
                let appPath = (appDir as NSString).appendingPathComponent(item)
                if let bundle = Bundle(path: appPath) {
                    let name = bundle.object(forInfoDictionaryKey: "CFBundleName") as? String ?? item.replacingOccurrences(of: ".app", with: "")
                    let bundleId = bundle.bundleIdentifier ?? "unknown.\(item)"
                    
                    foundApps.append(SystemApp(
                        id: bundleId,
                        name: name,
                        icon: "app", // Default icon for now
                        scheme: "",
                        category: .custom
                    ))
                }
            }
        } catch {
            print("Error scanning /Applications: \(error)")
        }
        
        return foundApps
    }
    #endif
}
