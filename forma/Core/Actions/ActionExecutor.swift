import Foundation
#if os(iOS)
import UIKit
#endif

class ActionExecutor {
    static let shared = ActionExecutor()
    
    private init() {}
    
    func execute(_ action: ActionNode) {
        switch action {
        case .openApp(let appId, let scheme):
            openApp(with: appId.bundleId, customScheme: scheme)
        case .openSpace(let id):
            print("Navigating to space: \(id)")
        case .shortcut(let name):
            print("Running shortcut: \(name)")
        case .siriIntent(let intent):
            print("Executing Siri Intent: \(intent)")
        case .url(let url):
            attemptOpen(schemes: [url.absoluteString])
        case .sequence(let actions):
            actions.forEach { execute($0) }
        }
    }
    
    private func openApp(with bundleId: String, customScheme: String?) {
        let schemeMap = [
            "com.apple.mail": ["message://", "mailto:"],
            "com.apple.Music": ["music://"],
            "com.apple.mobilesafari": ["https://", "http://"],
            "com.apple.calendar": ["calshow://"],
            "com.apple.Preferences": ["App-Prefs:"]
        ]
        
        let schemes = customScheme.map { [$0] } ?? (schemeMap[bundleId] ?? ["\(bundleId)://"])
        
        attemptOpen(schemes: schemes)
    }

    private func attemptOpen(schemes: [String]) {
        guard !schemes.isEmpty else { return }
        
        var remainingSchemes = schemes
        let currentScheme = remainingSchemes.removeFirst()
        
        guard let url = URL(string: currentScheme) else {
            attemptOpen(schemes: remainingSchemes)
            return
        }

        #if os(iOS)
        DispatchQueue.main.async {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:]) { success in
                    if !success {
                        self.attemptOpen(schemes: remainingSchemes)
                    }
                }
            } else {
                print("Cannot open \(currentScheme), trying next fallback if available...")
                self.attemptOpen(schemes: remainingSchemes)
            }
        }
        #else
        print("Opening URL: \(url) (Simulated on macOS)")
        #endif
    }
}
