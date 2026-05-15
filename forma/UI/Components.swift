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

struct AppIconView: View {
    let appID: AppID
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color(.secondarySystemGroupedBackground))
                    .frame(width: 60, height: 60)
                
                iconForApp(appID)
                    .font(.title2)
                    .foregroundStyle(Color.accentColor)
            }
            
            Text(nameForApp(appID))
                .font(.caption2)
                .lineLimit(1)
        }
    }
    
    @ViewBuilder
    private func iconForApp(_ appID: AppID) -> some View {
        if let app = (SystemApp.library + AppDiscoveryService.shared.availableApps).first(where: { $0.id == appID.bundleId }) {
            Image(systemName: app.icon)
        } else {
            Image(systemName: "app.dashed")
        }
    }
    
    private func nameForApp(_ appID: AppID) -> String {
        return (SystemApp.library + AppDiscoveryService.shared.availableApps).first(where: { $0.id == appID.bundleId })?.name ?? appID.bundleId.split(separator: ".").last?.capitalized ?? "App"
    }
}
