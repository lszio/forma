import Foundation
import SwiftUI
import Combine

// SICP: Stream-like processing of app discovery
@MainActor
class AppDiscoveryService: ObservableObject {
    @Published var availableApps: [SystemApp] = []
    @Published var isScanning = false
    
    static let shared = AppDiscoveryService()
    private let remoteRegistryURL = URL(string: "https://api.intentorganizer.com/v1/registry.json")
    
    private init() {}
    
    func performDiscovery() async {
        isScanning = true
        
        // 1. Load Static Library
        var potentialApps = SystemApp.library
        
        // 2. Fetch Remote Registry (Simulated)
        if let remoteApps = await fetchRemoteRegistry() {
            potentialApps.append(contentsOf: remoteApps)
        }
        
        // 3. De-duplicate by ID
        let uniqueApps = Array(Dictionary(grouping: potentialApps, by: { $0.id }).compactMap { $0.value.first })
        
        var found: [SystemApp] = []
        for app in uniqueApps {
            #if os(iOS)
            if let url = URL(string: app.scheme), UIApplication.shared.canOpenURL(url) {
                found.append(app)
            }
            #else
            found.append(app)
            #endif
            
            self.availableApps = found
            // Smaller delay for better UX
            try? await Task.sleep(nanoseconds: 5_000_000)
        }
        
        isScanning = false
    }
    
    private func fetchRemoteRegistry() async -> [SystemApp]? {
        // In a real implementation, this would be a URLSession call.
        // We simulate a small delay and returning a new app not in the static library.
        try? await Task.sleep(nanoseconds: 500_000_000)
        return [
            SystemApp(id: "com.disney.disneyplus", name: "Disney+", icon: "tv.fill", scheme: "disneyplus://", category: .entertainment)
        ]
    }
}
