import SwiftUI

struct SpaceCardView: View {
    let space: Space
    let isActive: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: space.icon)
                    .font(.title2)
                    .foregroundStyle(isActive ? .white : .accentColor)
                Spacer()
                if isActive {
                    Circle()
                        .fill(.white)
                        .frame(width: 8, height: 8)
                }
            }
            
            Spacer()
            
            Text(space.name)
                .font(.headline)
                .foregroundStyle(isActive ? .white : .primary)
        }
        .padding()
        .frame(height: 120)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(isActive ? Color.accentColor : Color(.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
    }
}

struct ActionIconView: View {
    let action: ActionNode
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color(.secondarySystemGroupedBackground))
                    .frame(width: 60, height: 60)
                
                iconForAction(action)
                    .font(.title2)
                    .foregroundStyle(Color.accentColor)
            }
            
            Text(nameForAction(action))
                .font(.caption2)
                .lineLimit(1)
        }
    }
    
    @ViewBuilder
    private func iconForAction(_ action: ActionNode) -> some View {
        switch action {
        case .openApp(let appId, _):
            if let app = SystemApp.library.first(where: { $0.id == appId.bundleId }) {
                Image(systemName: app.icon)
            } else {
                Image(systemName: "app.dashed")
            }
        case .url:
            Image(systemName: "link")
        case .shortcut:
            Image(systemName: "command")
        case .openSpace:
            Image(systemName: "arrow.right.circle")
        default:
            Image(systemName: "ellipsis.circle")
        }
    }
    
    private func nameForAction(_ action: ActionNode) -> String {
        switch action {
        case .openApp(let appId, _):
            return SystemApp.library.first(where: { $0.id == appId.bundleId })?.name ?? "App"
        case .url(let url):
            return url.host ?? "Link"
        default:
            return "Action"
        }
    }
}
