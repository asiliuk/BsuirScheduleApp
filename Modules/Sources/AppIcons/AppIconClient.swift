import UIKit
import Dependencies
import Foundation

public struct AppIconClient {
    public var alternateIconName: () -> String?
    public var supportsAlternateIcons: () -> Bool
    public var setAlternateIconName: @MainActor @Sendable (String?) async throws -> Void
}

extension AppIconClient {
    public static func empty() -> Self {
        AppIconClient(
            alternateIconName: { nil },
            supportsAlternateIcons: { false },
            setAlternateIconName: { _ in }
        )
    }
}

// MARK: - Dependency

extension DependencyValues {
    public var appIcons: AppIconClient {
        get { self[AppIconClientKey.self] }
        set { self[AppIconClientKey.self] = newValue }
    }
}

private enum AppIconClientKey: DependencyKey {
    static let liveValue = AppIconClient(application: .shared)
    static let testValue = AppIconClient.empty()
}

// MARK: - UIApplication

extension AppIconClient {
    init(application: UIApplication) {
        self.init(
            alternateIconName: { application.alternateIconName },
            supportsAlternateIcons: { application.supportsAlternateIcons },
            setAlternateIconName: { try await application.setAlternateIconName($0) }
        )
    }
}
