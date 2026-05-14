import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var contextManager = ContextManager()
    @StateObject private var resolver: IntentResolver
    
    init(modelContext: ModelContext) {
        _resolver = StateObject(wrappedValue: IntentResolver(modelContext: modelContext))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    SectionHeader(title: "Current Intent")
                    
                    if resolver.activeSpaces.isEmpty {
                        ContentUnavailableView("No Active Intent", systemImage: "sparkles", description: Text("Your context doesn't match any spaces right now."))
                            .frame(height: 200)
                    } else {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(resolver.activeSpaces) { space in
                                NavigationLink(value: space) {
                                    SpaceCardView(space: space, isActive: true)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    SectionHeader(title: "All Spaces")
                    
                    SpaceList(modelContext: modelContext, resolver: resolver)
                }
                .padding()
            }
            .navigationTitle("Intent Layer")
            .navigationDestination(for: Space.self) { space in
                SpaceDetailView(space: space)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: addDefaultSpaces) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .onAppear {
                resolver.update(with: contextManager.currentContext)
            }
        }
    }

    private func addDefaultSpaces() {
        let workSpace = Space(
            name: "Work",
            icon: "briefcase",
            actions: [.openApp(AppID(bundleId: "com.apple.mail"), scheme: "message://")],
            ruleTree: .time(TimeRule(startHour: 9, endHour: 18, weekdays: [2, 3, 4, 5, 6]))
        )
        
        let homeSpace = Space(
            name: "Home",
            icon: "house",
            actions: [.openApp(AppID(bundleId: "com.apple.Music"), scheme: "music://")],
            ruleTree: .or([
                .time(TimeRule(startHour: 18, endHour: 23, weekdays: [1, 2, 3, 4, 5, 6, 7])),
                .time(TimeRule(startHour: 7, endHour: 9, weekdays: [1, 2, 3, 4, 5, 6, 7]))
            ])
        )
        
        modelContext.insert(workSpace)
        modelContext.insert(homeSpace)

        resolver.update(with: contextManager.currentContext)
    }
}

struct SectionHeader: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.title3.bold())
            .padding(.top)
    }
}

struct SpaceList: View {
    let modelContext: ModelContext
    @ObservedObject var resolver: IntentResolver
    @Query private var allSpaces: [Space]
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(allSpaces) { space in
                if !resolver.activeSpaces.contains(where: { $0.id == space.id }) {
                    NavigationLink(value: space) {
                        SpaceCardView(space: space, isActive: false)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct SpaceDetailView: View {
    @Bindable var space: Space
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 20) {
                ForEach(0..<space.actions.count, id: \.self) { index in
                    ActionIconView(action: space.actions[index])
                        .onTapGesture {
                            ActionExecutor.shared.execute(space.actions[index])
                        }
                }
            }
            .padding()
        }
        .navigationTitle(space.name)
        .toolbar {
            ToolbarItem {
                NavigationLink {
                    SpaceEditorView(space: space)
                } label: {
                    Text("Edit")
                }
            }
        }
    }
}
