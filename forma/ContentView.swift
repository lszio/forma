import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Space.lastModified, order: .reverse) private var spaces: [Space]
    @StateObject private var discoveryService = AppDiscoveryService.shared
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(spaces) { space in
                        NavigationLink(destination: SpaceEditorView(space: space)) {
                            HStack(spacing: 15) {
                                Image(systemName: space.icon)
                                    .foregroundStyle(.white)
                                    .padding(8)
                                    .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 8))
                                
                                VStack(alignment: .leading) {
                                    Text(space.name)
                                        .font(.headline)
                                    if space.isAllAppsSpace {
                                        Text("Auto-syncing all apps")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    } else if !space.tags.isEmpty {
                                        Text(space.tags.joined(separator: ", "))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Text("\(space.appIds.count) Apps")
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color(.systemGray5), in: Capsule())
                            }
                        }
                    }
                    .onDelete(perform: deleteSpaces)
                } header: {
                    Text("Your Spaces")
                }
                
                Button(action: addSpace) {
                    Label("Create New Space", systemImage: "plus.circle.fill")
                }
            }
            .navigationTitle("Forma")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { discoveryService.performDiscovery() }) {
                        Image(systemName: "arrow.clockwise.circle")
                    }
                }
            }
            .onAppear {
                discoveryService.performDiscovery()
                ensureDefaultSpace()
            }
            .onChange(of: discoveryService.discoveredApps) { _ in
                syncAllAppsSpace()
            }
        }
    }
    
    private func ensureDefaultSpace() {
        if !spaces.contains(where: { $0.isAllAppsSpace }) {
            let dashboard = Space(
                name: "All Apps", 
                icon: "square.grid.2x2.fill", 
                tags: ["System"], 
                appIds: discoveryService.discoveredApps.map { $0.id },
                isAllAppsSpace: true
            )
            modelContext.insert(dashboard)
            try? modelContext.save()
        }
    }
    
    private func syncAllAppsSpace() {
        if let allAppsSpace = spaces.first(where: { $0.isAllAppsSpace }) {
            let newIds = discoveryService.discoveredApps.map { $0.id }
            if allAppsSpace.appIds != newIds {
                allAppsSpace.appIds = newIds
                allAppsSpace.lastModified = Date()
                try? modelContext.save()
            }
        }
    }
    
    private func addSpace() {
        let newSpace = Space(name: "New Space", icon: "folder.fill")
        modelContext.insert(newSpace)
        try? modelContext.save()
    }
    
    private func deleteSpaces(offsets: IndexSet) {
        for index in offsets {
            let space = spaces[index]
            if !space.isAllAppsSpace {
                modelContext.delete(space)
            }
        }
        try? modelContext.save()
    }
}
