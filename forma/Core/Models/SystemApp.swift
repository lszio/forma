import Foundation

struct SystemApp: Identifiable, Codable {
    let id: String // bundleId
    let name: String
    let icon: String
    let scheme: String
    let category: AppCategory
    
    enum AppCategory: String, Codable, CaseIterable {
        case system = "System"
        case social = "Social"
        case entertainment = "Entertainment"
        case productivity = "Productivity"
        case custom = "Custom"
    }
    
    static let library: [SystemApp] = [
        // System
        SystemApp(id: "com.apple.mobilesafari", name: "Safari", icon: "safari", scheme: "https://", category: .system),
        SystemApp(id: "com.apple.Music", name: "Music", icon: "music.note", scheme: "music://", category: .system),
        SystemApp(id: "com.apple.mail", name: "Mail", icon: "envelope", scheme: "message://", category: .system),
        SystemApp(id: "com.apple.calendar", name: "Calendar", icon: "calendar", scheme: "calshow://", category: .system),
        SystemApp(id: "com.apple.Maps", name: "Maps", icon: "map", scheme: "maps://", category: .system),
        SystemApp(id: "com.apple.Preferences", name: "Settings", icon: "gear", scheme: "App-Prefs:", category: .system),
        SystemApp(id: "com.apple.mobileslideshow", name: "Photos", icon: "photo.on.rectangle", scheme: "photos-redirect://", category: .system),
        SystemApp(id: "com.apple.camera", name: "Camera", icon: "camera", scheme: "camera://", category: .system),
        SystemApp(id: "com.apple.mobilenotes", name: "Notes", icon: "note.text", scheme: "mobilenotes://", category: .system),
        SystemApp(id: "com.apple.reminders", name: "Reminders", icon: "list.bullet.rectangle", scheme: "x-apple-reminder://", category: .system),
        SystemApp(id: "com.apple.calculator", name: "Calculator", icon: "plus.forwardslash.minus", scheme: "calc://", category: .system),
        SystemApp(id: "com.apple.iBooks", name: "Books", icon: "book", scheme: "ibooks://", category: .system),
        SystemApp(id: "com.apple.DocumentsApp", name: "Files", icon: "folder", scheme: "shareddocuments://", category: .system),
        
        // Social
        SystemApp(id: "com.tencent.xin", name: "WeChat", icon: "message.fill", scheme: "weixin://", category: .social),
        SystemApp(id: "com.tencent.mqq", name: "QQ", icon: "bubble.left.and.bubble.right.fill", scheme: "mqq://", category: .social),
        SystemApp(id: "net.whatsapp.WhatsApp", name: "WhatsApp", icon: "phone.circle.fill", scheme: "whatsapp://", category: .social),
        SystemApp(id: "com.instagram.da_vince", name: "Instagram", icon: "camera.fill", scheme: "instagram://", category: .social),
        SystemApp(id: "com.atebits.Tweetie2", name: "X", icon: "x.circle.fill", scheme: "twitter://", category: .social),
        SystemApp(id: "org.telegram.messenger", name: "Telegram", icon: "paperplane.fill", scheme: "tg://", category: .social),
        SystemApp(id: "com.facebook.Messenger", name: "Messenger", icon: "bolt.horizontal.circle.fill", scheme: "fb-messenger://", category: .social),
        
        // Entertainment
        SystemApp(id: "com.spotify.client", name: "Spotify", icon: "waveform", scheme: "spotify://", category: .entertainment),
        SystemApp(id: "com.google.ios.youtube", name: "YouTube", icon: "play.rectangle.fill", scheme: "youtube://", category: .entertainment),
        SystemApp(id: "com.zhiliaoapp.musically", name: "TikTok", icon: "music.note", scheme: "snssdk1233://", category: .entertainment),
        SystemApp(id: "com.netflix.Netflix", name: "Netflix", icon: "play.tv.fill", scheme: "nflx://", category: .entertainment),
        
        // Productivity
        SystemApp(id: "com.tinyspeck.chatlyio", name: "Slack", icon: "bubbles.and.sparkles.fill", scheme: "slack://", category: .productivity),
        SystemApp(id: "com.notion.Notion", name: "Notion", icon: "doc.text.fill", scheme: "notion://", category: .productivity),
        SystemApp(id: "us.zoom.videoconference", name: "Zoom", icon: "video.fill", scheme: "zoomus://", category: .productivity),
        SystemApp(id: "com.microsoft.Teams", name: "Teams", icon: "person.2.fill", scheme: "msteams://", category: .productivity),
        SystemApp(id: "com.google.Drive", name: "Google Drive", icon: "cloud.fill", scheme: "googledrive://", category: .productivity)
    ]
}
