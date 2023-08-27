import Foundation
import Dependencies

public struct AppConfiguration: Equatable {
    public let telemetryDeckAppId: String?
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
    public static let previewValue = AppConfiguration(telemetryDeckAppId: "xxx-xxx-xxx")
}

// MARK: - Info.plist

private extension AppConfiguration {
    init(infoDictionary: [String: Any]?) {
        self.telemetryDeckAppId = (infoDictionary?["TELEMETRY_DECK_APP_ID"] as? String)?.nilOnEmpty()
    }
}
