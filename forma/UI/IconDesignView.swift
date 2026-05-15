import SwiftUI

struct IconDesignView: View {
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                colors: [Color(hex: "1A1A2E"), Color(hex: "16213E")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Text("forma")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .tracking(4)
                
                // Icon Preview
                ZStack {
                    // Base Layer
                    SpaceLayer(color: .blue, rotation: -15, offset: -20)
                    
                    // Middle Layer
                    SpaceLayer(color: .purple, rotation: 0, offset: 0)
                    
                    // Top Layer
                    SpaceLayer(color: .cyan, rotation: 15, offset: 20)
                }
                .frame(width: 200, height: 200)
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                
                Text("The Prismatic Layers")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct SpaceLayer: View {
    let color: Color
    let rotation: Double
    let offset: CGFloat
    
    var body: some View {
        RoundedRectangle(cornerRadius: 32, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke(color.opacity(0.5), lineWidth: 2)
            )
            .rotationEffect(.degrees(rotation))
            .offset(x: offset, y: offset)
            .frame(width: 140, height: 140)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    IconDesignView()
}
