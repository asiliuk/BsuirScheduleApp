import UIKit

public struct ApplicationClient {
    public var open: @MainActor @Sendable (URL, [UIApplication.OpenExternalURLOptionsKey: Any]) async -> Bool
    public var alternateIconName: () -> String?
    public var supportsAlternateIcons: () -> Bool
    public var setAlternateIconName: @MainActor @Sendable (String?) async throws -> Void
}

extension ApplicationClient {
    init(application: UIApplication) {
        self.init(
            open: { await application.open($0, options: $1) },
            alternateIconName: { application.alternateIconName },
            supportsAlternateIcons: { application.supportsAlternateIcons },
            setAlternateIconName: { try await application.setAlternateIconName($0) }
        )
    }
}
