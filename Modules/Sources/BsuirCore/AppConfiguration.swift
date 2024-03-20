import Foundation
import Dependencies

public struct AppConfiguration: Equatable {
    // Something will be added here later
}

// MARK: - Dependency

extension DependencyValues {
    public var appConfiguration: AppConfiguration {
        get { self[AppConfiguration.self] }
        set { self[AppConfiguration.self] = newValue }
    }
}

extension AppConfiguration: DependencyKey {
    public static let liveValue = AppConfiguration(infoDictionary: Bundle.main.infoDictionary)
    public static let previewValue = AppConfiguration()
}

// MARK: - Info.plist

private extension AppConfiguration {
    init(infoDictionary: [String: Any]?) {
        // Parse configuration from Info.plist
    }
}
