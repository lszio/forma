import SwiftUI
import SwiftData

struct AppGalleryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var discoveryService = AppDiscoveryService.shared
    @State private var searchText = ""
    
    let onSelect: (SystemApp) -> Void
    
    var filteredApps: [SystemApp] {
        if searchText.isEmpty {
            return discoveryService.availableApps
        } else {
            return discoveryService.availableApps.filter { 
                $0.name.localizedCaseInsensitiveContains(searchText) || 
                $0.id.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if discoveryService.isScanning && discoveryService.availableApps.isEmpty {
                    VStack(spacing: 20) {
                        ProgressView()
                        Text("Discovering apps...")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    List {
                        ForEach(SystemApp.AppCategory.allCases, id: \.self) { category in
                            let apps = filteredApps.filter { $0.category == category }
                            if !apps.isEmpty {
                                Section(category.rawValue) {
                                    ForEach(apps) { app in
                                        AppRow(app: app) {
                                            onSelect(app)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search apps")
                }
            }
            .navigationTitle("App Gallery")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { Task { await discoveryService.performDiscovery() } }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(discoveryService.isScanning)
                }
            }
            .task {
                if discoveryService.availableApps.isEmpty {
                    await discoveryService.performDiscovery()
                }
            }
        }
    }
}

struct AppRow: View {
    let app: SystemApp
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: app.icon)
                    .font(.title2)
                    .foregroundStyle(Color.accentColor)
                    .frame(width: 32, height: 32)
                
                VStack(alignment: .leading) {
                    Text(app.name)
                        .font(.headline)
                    Text(app.id)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "plus.circle")
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
    }
}
