import Foundation

struct AppRegistry: Sendable {
    static let shared = AppRegistry()
    
    let library: [SystemApp] = [
        SystemApp(id: "com.apple.Music", name: "Music", icon: "music.note", scheme: "music://", category: .entertainment),
        SystemApp(id: "com.apple.mail", name: "Mail", icon: "envelope.fill", scheme: "message://", category: .productivity),
        SystemApp(id: "com.apple.mobilesafari", name: "Safari", icon: "safari.fill", scheme: "https://", category: .productivity),
        SystemApp(id: "com.apple.calendar", name: "Calendar", icon: "calendar", scheme: "calshow://", category: .productivity),
        SystemApp(id: "com.apple.Notes", name: "Notes", icon: "note.text", scheme: "mobilenotes://", category: .productivity),
        SystemApp(id: "com.spotify.client", name: "Spotify", icon: "waveform", scheme: "spotify://", category: .entertainment)
    ]
    
    func get(id: String) -> SystemApp? {
        library.first { $0.id == id }
    }
    
    var allBundleIds: [String] {
        library.map { $0.id }
    }
}

struct SystemApp: Identifiable, Codable, Sendable, Equatable {
    let id: String
    let name: String
    let icon: String
    let scheme: String
    let category: AppCategory
    
    enum AppCategory: String, Codable, CaseIterable, Sendable {
        case productivity = "Productivity"
        case entertainment = "Entertainment"
        case social = "Social"
        case system = "System"
    }
}
