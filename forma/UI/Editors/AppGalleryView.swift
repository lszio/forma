import SwiftUI
import SwiftData

struct AppGalleryView: View {
    @Environment(\.dismiss) private var dismiss
    
    let onSelect: (SystemApp) -> Void
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(SystemApp.AppCategory.allCases, id: \.self) { category in
                    let apps = SystemApp.library.filter { $0.category == category }
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
                                                .font(.headline)
                                            Text(app.id)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        Image(systemName: "plus.circle")
                                            .foregroundStyle(Color.accentColor)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add App")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
