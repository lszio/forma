import AppIntents
import Foundation

struct OpenSpaceIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Space"
    static var description = IntentDescription("Opens a specific intent space.")
    static var openAppWhenRun: Bool = true

    @Parameter(title: "Space")
    var spaceName: String

    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        // In a real app, this would use deep linking or a shared state to open the space
        // For now, we return the space name as a result
        return .result(value: spaceName)
    }
}
