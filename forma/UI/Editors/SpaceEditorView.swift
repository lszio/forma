import SwiftUI

struct SpaceEditorView: View {
    @Bindable var space: Space
    @State private var showingAppPicker = false
    @State private var showingCustomAppForm = false
    
    var body: some View {
        Form {
            Section("General") {
                TextField("Name", text: $space.name)
                TextField("Icon", text: $space.icon)
            }
            
            Section("Rule") {
                NavigationLink("Edit Rule Tree") {
                    RuleEditorView(rule: $space.ruleTree)
                }
            }
            
            Section("Actions") {
                ForEach(0..<space.actions.count, id: \.self) { index in
                    ActionEditorRow(action: Binding(get: { space.actions[index] }, set: { space.actions[index] = $0 }))
                }
                .onDelete { indices in
                    var actions = space.actions
                    actions.remove(atOffsets: indices)
                    space.actions = actions
                }
                
                Button("Add App from Library") {
                    showingAppPicker = true
                }
                
                Button("Add Custom App (URL/Scheme)") {
                    showingCustomAppForm = true
                }
            }
        }
        .navigationTitle("Edit Space")
        .sheet(isPresented: $showingAppPicker) {
            AppPickerView { app in
                var actions = space.actions
                actions.append(.openApp(AppID(bundleId: app.id), scheme: app.scheme))
                space.actions = actions
                showingAppPicker = false
            }
        }
        .sheet(isPresented: $showingCustomAppForm) {
            CustomAppFormView { name, scheme, icon in
                var actions = space.actions
                // We use a pseudo bundle ID for custom apps
                actions.append(.openApp(AppID(bundleId: "custom.\(name.lowercased())"), scheme: scheme))
                space.actions = actions
                showingCustomAppForm = false
            }
        }
    }
}

struct CustomAppFormView: View {
    @State private var name = ""
    @State private var scheme = ""
    @State private var icon = "app"
    @Environment(\.dismiss) var dismiss
    
    let onSave: (String, String, String) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("App Name", text: $name)
                TextField("URL Scheme (e.g. weixin://)", text: $scheme)
                    .textInputAutocapitalization(.never)
                TextField("Icon Name (SF Symbol)", text: $icon)
            }
            .navigationTitle("Custom App")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(name, scheme, icon)
                    }
                    .disabled(name.isEmpty || scheme.isEmpty)
                }
            }
        }
    }
}

struct AppPickerView: View {
    let onSelect: (SystemApp) -> Void
    @Environment(\.dismiss) var dismiss
    @StateObject private var discoveryService = AppDiscoveryService.shared
    
    var body: some View {
        NavigationStack {
            Group {
                if discoveryService.isScanning && discoveryService.availableApps.isEmpty {
                    VStack(spacing: 20) {
                        ProgressView()
                        Text("Automatically discovering apps...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } else if discoveryService.availableApps.isEmpty {
                    ContentUnavailableView(
                        "No Apps Detected",
                        systemImage: "app.badge.warning",
                        description: Text("Could not find any supported apps on this device.")
                    )
                } else {
                    List {
                        ForEach(SystemApp.AppCategory.allCases.filter { $0 != .custom }, id: \.self) { category in
                            let apps = discoveryService.availableApps.filter { $0.category == category }
                            if !apps.isEmpty {
                                Section(category.rawValue) {
                                    ForEach(apps) { app in
                                        Button {
                                            onSelect(app)
                                        } label: {
                                            Label(app.name, systemImage: app.icon)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Discovered Apps")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    if discoveryService.isScanning {
                        ProgressView()
                    } else {
                        Button("Rescan") {
                            Task { await discoveryService.performDiscovery() }
                        }
                    }
                }
            }
            .task {
                await discoveryService.performDiscovery()
            }
        }
    }
}

struct ActionEditorRow: View {
    @Binding var action: ActionNode
    
    var body: some View {
        switch action {
        case .openApp(let appId, let scheme):
            VStack(alignment: .leading) {
                Text(appId.bundleId).font(.caption).foregroundStyle(.secondary)
                TextField("Scheme", text: Binding(get: { scheme ?? "" }, set: { action = .openApp(appId, scheme: $0.isEmpty ? nil : $0) }))
            }
        case .url(let url):
            TextField("URL", text: Binding(get: { url.absoluteString }, set: { if let newURL = URL(string: $0) { action = .url(newURL) } }))
        default:
            Text("Action editing not fully implemented")
        }
    }
}
