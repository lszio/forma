import Foundation

struct ContextEntity: Identifiable, Hashable, Codable, Sendable {
    var id: String
    var type: String
    var value: String
    var timestamp: TimeInterval
    var confidence: Double
    
    init(id: String, type: String, value: String, confidence: Double = 1.0) {
        self.id = id
        self.type = type
        self.value = value
        self.timestamp = Date().timeIntervalSince1970
        self.confidence = confidence
    }
}
