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
            // If creation fails, it might be due to an incompatible schema.
            // In a production app, you'd perform a migration. 
            // For this dev version, we can attempt to recreate the container by clearing the store.
            print("ModelContainer initialization failed: \(error). Attempting to recreate...")
            
            // Try in-memory as a fallback to avoid crash
            let inMemoryConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            do {
                return try ModelContainer(for: schema, configurations: [inMemoryConfig])
            } catch {
                fatalError("Could not create ModelContainer even in memory: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView(modelContext: sharedModelContainer.mainContext)
        }
        .modelContainer(sharedModelContainer)
    }
}
