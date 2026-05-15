import SwiftUI
import SwiftData

struct SpaceEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var space: Space
    @State private var showingAppPicker = false
    @State private var showingCustomAppForm = false
    @State private var newTag = ""
    
    var body: some View {
        Form {
            Section("General") {
                TextField("Name", text: $space.name)
                TextField("Icon (SF Symbol)", text: $space.icon)
                
                Toggle("Enable Rule Processing", isOn: Binding(get: { space.safeIsEnabled }, set: { space.isEnabled = $0 }))
            }
            
            Section("Tags") {
                HStack {
                    TextField("Add tag...", text: $newTag)
                        .onSubmit {
                            addTag()
                        }
                    Button(action: addTag) {
                        Image(systemName: "plus.circle.fill")
                    }
                    .disabled(newTag.isEmpty)
                }
                
                FlowLayout(spacing: 8) {
                    ForEach(space.safeTags, id: \.self) { tag in
                        TagView(tag: tag) {
                            var tags = space.safeTags
                            tags.removeAll { $0 == tag }
                            space.tags = tags
                        }
                    }
                }
            }
            
            Section("Sorting & Recommendation") {
                Picker("Ranking Rule", selection: Binding(get: { space.safeRankingRule }, set: { space.rankingRule = $0 })) {
                    ForEach(RankingRule.allCases, id: \.self) { rule in
                        Text(rule.rawValue).tag(rule)
                    }
                }
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
            
            Section {
                Button("Delete Space", role: .destructive) {
                    modelContext.delete(space)
                    dismiss()
                }
            }
        }
        .navigationTitle("Edit Space")
        .sheet(isPresented: $showingAppPicker) {
            AppGalleryView { app in
                var actions = space.actions
                actions.append(.openApp(AppID(bundleId: app.id), scheme: app.scheme))
                space.actions = actions
                showingAppPicker = false
            }
        }
        .sheet(isPresented: $showingCustomAppForm) {
            CustomAppFormView { name, scheme, icon in
                var actions = space.actions
                actions.append(.openApp(AppID(bundleId: "custom.\(name.lowercased())"), scheme: scheme))
                space.actions = actions
                showingCustomAppForm = false
            }
        }
    }
    
    private func addTag() {
        let tag = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        if !tag.isEmpty && !space.safeTags.contains(tag) {
            var tags = space.safeTags
            tags.append(tag)
            space.tags = tags
            newTag = ""
        }
    }
}

struct TagView: View {
    let tag: String
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(tag)
                .font(.caption)
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption2)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.secondary.opacity(0.2))
        .clipShape(Capsule())
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxWidth: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > width {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            maxWidth = max(maxWidth, currentX)
        }
        
        return CGSize(width: maxWidth, height: currentY + lineHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX = bounds.minX
        var currentY = bounds.minY
        var lineHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > bounds.maxX {
                currentX = bounds.minX
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            subview.place(at: CGPoint(x: currentX, y: currentY), proposal: .unspecified)
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
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
