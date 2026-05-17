import SwiftUI
import SwiftData

struct SpaceEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var space: Space
    @State private var showingAppPicker = false
    @State private var newTag = ""
    
    var body: some View {
        Form {
            Section("General") {
                TextField("Name", text: $space.name)
                TextField("Icon (SF Symbol)", text: $space.icon)
            }
            
            Section("Tags (for Affinity Engine)") {
                HStack {
                    TextField("Add tag", text: $newTag)
                    Button("Add") {
                        if !newTag.isEmpty {
                            var currentTags = space.tags
                            currentTags.append(newTag)
                            space.tags = currentTags
                            newTag = ""
                        }
                    }
                }
                
                ForEach(space.tags, id: \.self) { tag in
                    HStack {
                        Text(tag)
                        Spacer()
                        Button(role: .destructive) {
                            var currentTags = space.tags
                            currentTags.removeAll { $0 == tag }
                            space.tags = currentTags
                        } label: {
                            Image(systemName: "xmark.circle")
                        }
                    }
                }
            }
            
            Section("Apps (Ordered)") {
                List {
                    ForEach(space.appIds, id: \.self) { appId in
                        if let app = AppRegistry.shared.get(id: appId) {
                            HStack {
                                Image(systemName: app.icon)
                                    .foregroundStyle(Color.accentColor)
                                Text(app.name)
                            }
                        }
                    }
                    .onDelete { indices in
                        var currentAppIds = space.appIds
                        currentAppIds.remove(atOffsets: indices)
                        space.appIds = currentAppIds
                    }
                }
                
                Button("Add App") { showingAppPicker = true }
            }
            
            Section {
                Button("Delete Space", role: .destructive) {
                    modelContext.delete(space)
                    dismiss()
                }
            }
        }
        .navigationTitle("Edit Space")
        .sheet(isPresented: $showingAppPicker) {
            AppGalleryView { selectedApp in
                var currentAppIds = space.appIds
                if !currentAppIds.contains(selectedApp.id) {
                    currentAppIds.append(selectedApp.id)
                    space.appIds = currentAppIds
                }
            }
        }
    }
}

struct AppGalleryView: View {
    @Environment(\.dismiss) private var dismiss
    let onSelect: (SystemApp) -> Void
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(SystemApp.AppCategory.allCases, id: \.self) { category in
                    let apps = AppDiscoveryService.shared.discoveredApps.filter { $0.category == category }
                    if !apps.isEmpty {
                        Section(category.rawValue) {
                            ForEach(apps) { app in
                                Button {
                                    onSelect(app)
                                    dismiss()
                                } label: {
                                    HStack {
                                        Image(systemName: app.icon)
                                            .frame(width: 30)
                                        VStack(alignment: .leading) {
                                            Text(app.name)
                                                .font(.subheadline)
                                            Text(app.id)
                                                .font(.caption2)
                                                .foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        Image(systemName: "plus.circle")
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add App")
        }
    }
}
