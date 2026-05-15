import Foundation

struct AppID: Hashable, Codable, Identifiable, Sendable {
    let bundleId: String
    var id: String { bundleId }
}
