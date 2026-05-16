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
                Toggle("Dynamic Learning", isOn: $space.isDynamic)
            }
            
            Section("Tags & Automation") {
                HStack {
                    TextField("Add tag (e.g. Work, Morning)", text: $newTag)
                    Button("Add") {
                        if !newTag.isEmpty {
                            space.tags.append(newTag)
                            newTag = ""
                        }
                    }
                }
                
                FlowLayout(spacing: 8) {
                    ForEach(space.tags, id: \.self) { tag in
                        Text(tag)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.accentColor.opacity(0.1))
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color.accentColor, lineWidth: 1))
                            .onTapGesture {
                                space.tags.removeAll { $0 == tag }
                            }
                    }
                }
                .padding(.vertical, 5)
            }
            
            Section("App Ordering (Drag to sort)") {
                List {
                    ForEach(space.orderedAppIds, id: \.self) { bundleId in
                        HStack {
                            Image(systemName: "app")
                            Text(bundleId)
                        }
                    }
                    .onMove { indices, newOffset in
                        space.orderedAppIds.move(fromOffsets: indices, toOffset: newOffset)
                    }
                    .onDelete { indices in
                        space.orderedAppIds.remove(atOffsets: indices)
                    }
                }
                
                Button(action: { showingAppPicker = true }) {
                    Label("Add App to Space", systemImage: "plus")
                }
            }
            
            Section("Advanced Rules") {
                if space.rules.isEmpty {
                    Text("No complex rules defined").foregroundStyle(.secondary)
                } else {
                    ForEach(space.rules) { rule in
                        Text("Rule: \(rule.id.uuidString.prefix(4))")
                    }
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
                if !space.orderedAppIds.contains(selectedApp.id) {
                    space.orderedAppIds.append(selectedApp.id)
                }
            }
        }
    }
}

// Simple FlowLayout for tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        var width: CGFloat = proposal.width ?? 300
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        
        for size in sizes {
            if currentX + size.width > width {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        return CGSize(width: width, height: currentY + lineHeight)
    }
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX: CGFloat = bounds.minX
        var currentY: CGFloat = bounds.minY
        var lineHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > bounds.maxX {
                currentX = bounds.minX
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            subview.place(at: CGPoint(x: currentX, y: currentY), proposal: ProposedViewSize(size))
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}
