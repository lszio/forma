import SwiftUI
import SwiftData

struct SpaceEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var space: Space
    @State private var showingAppPicker = false
    @State private var showingCustomAppForm = false
    
    var body: some View {
        Form {
            Section("General") {
                TextField("Name", text: $space.name)
                TextField("Icon (SF Symbol)", text: $space.icon)
                
                Toggle("Dynamic Learning", isOn: $space.isDynamic)
            }
            
            Section("Space Apps") {
                let targetApps = Array(Set(space.rules.flatMap { $0.targetApps } + space.learningWeights.keys.map { AppID(bundleId: $0) }))
                
                ForEach(targetApps) { appID in
                    HStack {
                        Image(systemName: "app")
                        Text(appID.bundleId)
                        Spacer()
                        Button(role: .destructive) {
                            removeApp(appID)
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                }
                
                Button(action: { showingAppPicker = true }) {
                    Label("Add App to Space", systemImage: "plus")
                }
            }
            
            Section("Rules") {
                if space.rules.isEmpty {
                    Text("No rules defined")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(space.rules) { rule in
                        Text("Rule ID: \(rule.id.uuidString.prefix(8))")
                    }
                }
                // We will build a visual Rule Editor later
                Button("Add Rule (Placeholder)") {
                    // Action
                }
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
                addApp(selectedApp)
            }
        }
    }
    
    private func addApp(_ app: SystemApp) {
        // We add the app by creating a simple rule or adding it to weights
        // For simplicity in this UI, let's add it to a "General" rule for the space
        let newAppID = AppID(bundleId: app.id)
        var currentRules = space.rules
        
        if let index = currentRules.firstIndex(where: { $0.priority == 0 }) {
            // Add to existing general rule
            var apps = currentRules[index].targetApps
            if !apps.contains(where: { $0.bundleId == newAppID.bundleId }) {
                apps.append(newAppID)
                let updatedRule = Rule(id: currentRules[index].id, triggerNode: currentRules[index].triggerNode, targetApps: apps, priority: 0)
                currentRules[index] = updatedRule
            }
        } else {
            // Create a general rule that's always true for this space
            let alwaysTrue = RuleNode.or([]) // Empty OR is false, let's use a better always-true
            // Actually, a rule with no specific constraints or a time rule covering 24h
            let generalRule = Rule(triggerNode: .not(.or([])), targetApps: [newAppID], priority: 0)
            currentRules.append(generalRule)
        }
        space.rules = currentRules
    }
    
    private func removeApp(_ appID: AppID) {
        var currentRules = space.rules
        for i in 0..<currentRules.count {
            var apps = currentRules[i].targetApps
            apps.removeAll { $0.bundleId == appID.bundleId }
            currentRules[i] = Rule(id: currentRules[i].id, triggerNode: currentRules[i].triggerNode, targetApps: apps, priority: currentRules[i].priority)
        }
        space.rules = currentRules
        
        var weights = space.learningWeights
        weights.removeValue(forKey: appID.bundleId)
        space.learningWeights = weights
    }
}
