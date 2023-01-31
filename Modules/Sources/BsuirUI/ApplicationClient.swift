import UIKit

public struct ApplicationClient {
    public var alternateIconName: () -> String?
    public var supportsAlternateIcons: () -> Bool
    public var setAlternateIconName: @MainActor @Sendable (String?) async throws -> Void
}

extension ApplicationClient {
    init(application: UIApplication) {
        self.init(
            alternateIconName: { application.alternateIconName },
            supportsAlternateIcons: { application.supportsAlternateIcons },
            setAlternateIconName: { try await application.setAlternateIconName($0) }
        )
    }
}
