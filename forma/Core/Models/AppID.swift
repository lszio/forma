import Foundation

struct AppID: Hashable, Codable, Identifiable {
    let bundleId: String
    var id: String { bundleId }
}
