import Foundation

struct RuntimeContextGraph: Sendable {
    private(set) var entities: [String: ContextEntity] = [:]
    
    mutating func update(entity: ContextEntity) {
        entities[entity.id] = entity
    }
    
    mutating func remove(id: String) {
        entities.removeValue(forKey: id)
    }
    
    func has(type: String, value: String) -> Bool {
        entities.values.contains { $0.type == type && $0.value == value }
    }
    
    func has(id: String) -> Bool {
        entities.keys.contains(id)
    }
    
    func get(id: String) -> ContextEntity? {
        entities[id]
    }
}
