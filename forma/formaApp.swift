//
//  formaApp.swift
//  forma
//
//  Created by lszio on 2026/5/14.
//

import SwiftUI
import SwiftData

@main
struct formaApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Space.self,
            DiscoveredApp.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView(modelContext: sharedModelContainer.mainContext)
        }
        .modelContainer(sharedModelContainer)
    }
}
