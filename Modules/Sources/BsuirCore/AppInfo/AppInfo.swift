import Foundation
import Dependencies

public struct AppInfo {
    public let version: FullAppVersion
    public let iconName: String?

    public init(version: FullAppVersion, iconName: String?) {
        self.version = version
        self.iconName = iconName
    }
}


public extension AppInfo {
    init(bundle: Bundle) {
        self.init(
            version: bundle.fullVersion,
            iconName: bundle.infoDictionary
                .flatMap { info in info["CFBundleIcons"] as? [String: Any] }
                .flatMap { icons in icons["CFBundlePrimaryIcon"] as? [String: Any] }
                .flatMap { primaryIcon in primaryIcon["CFBundleIconFiles"] as? [String] }
                .flatMap { icons in icons.last }
        )
    }
}

// MARK: - Dependency

extension DependencyValues {
    public var appInfo: AppInfo {
        get { self[AppInfoKey.self] }
        set { self[AppInfoKey.self] = newValue }
    }
}

private enum AppInfoKey: DependencyKey {
    static let liveValue = AppInfo(bundle: .main)
    static let previewValue = AppInfo(
        version: FullAppVersion(short: "3.0.0", build: 100),
        iconName: nil
    )
    static let testValue = AppInfo(
        version: FullAppVersion(short: "1.0.0", build: 100),
        iconName: nil
    )
}
