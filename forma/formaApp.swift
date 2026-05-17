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
            Space.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .private("iCloud.lszio.forma")
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            print("ModelContainer initialization failed: \(error). Falling back to local...")
            let localConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            do {
                return try ModelContainer(for: schema, configurations: [localConfig])
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
