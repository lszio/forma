import Foundation

enum ActionNode: Codable {
    case openApp(AppID, scheme: String?)
    case openSpace(UUID)
    case shortcut(String)
    case siriIntent(String)
    case url(URL)
    case sequence([ActionNode])
}
