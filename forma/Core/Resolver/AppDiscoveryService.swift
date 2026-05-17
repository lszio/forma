import Foundation
import Combine
#if os(iOS)
import UIKit
#endif

@MainActor
class AppDiscoveryService: ObservableObject {
    static let shared = AppDiscoveryService()
    
    @Published var discoveredApps: [SystemApp] = []
    
    private init() {
        self.discoveredApps = AppRegistry.shared.library
    }
    
    /// Scans the system for installed apps using known URL schemes.
    func performDiscovery() {
        #if os(iOS)
        var updatedApps = AppRegistry.shared.library
        
        // Extended list of common iOS app schemes
        let commonSchemes = [
            "youtube://", "twitter://", "instagram://", "fb://", 
            "slack://", "microsoft-edge://", "googlechrome://",
            "spotify://", "whatsapp://", "tg://", "discord://",
            "zoomus://", "notion://", "linear://"
        ]
        
        for scheme in commonSchemes {
            if let url = URL(string: scheme), UIApplication.shared.canOpenURL(url) {
                let id = scheme.replacingOccurrences(of: "://", with: "")
                if !updatedApps.contains(where: { $0.scheme == scheme }) {
                    updatedApps.append(SystemApp(
                        id: "com.discovered.\(id)",
                        name: id.capitalized,
                        icon: "app.badge.fill",
                        scheme: scheme,
                        category: .system
                    ))
                }
            }
        }
        self.discoveredApps = updatedApps
        #endif
    }
}
