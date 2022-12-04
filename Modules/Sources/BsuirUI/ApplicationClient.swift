import UIKit

public struct ApplicationClient {
    public var open: @Sendable (URL, [UIApplication.OpenExternalURLOptionsKey: Any]) async -> Bool
    public var alternateIconName: @Sendable () async -> String?
    public var supportsAlternateIcons: @Sendable () async -> Bool
    public var setAlternateIconName: @Sendable (String?) async throws -> Void
}

extension ApplicationClient {
    init(application: UIApplication) {
        self.init(
            open: { @MainActor in await application.open($0, options: $1) },
            alternateIconName: { await application.alternateIconName },
            supportsAlternateIcons: { await application.supportsAlternateIcons },
            setAlternateIconName: { @MainActor in try await application.setAlternateIconName($0) }
        )
    }
}
