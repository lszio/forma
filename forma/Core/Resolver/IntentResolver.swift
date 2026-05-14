import Foundation
import SwiftData
import Combine

@MainActor
class IntentResolver: ObservableObject {
    @Published var activeSpaces: [Space] = []
    
    private let engine = RuleEngine()
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func update(with context: Context) {
        let descriptor = FetchDescriptor<Space>()
        do {
            let allSpaces = try modelContext.fetch(descriptor)
            activeSpaces = engine.resolve(spaces: allSpaces, context: context)
        } catch {
            print("Failed to fetch spaces: \(error)")
        }
    }
}
