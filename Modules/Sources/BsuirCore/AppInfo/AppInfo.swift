import Foundation

public struct AppInfo {
    public let version: FullAppVersion
    public let iconName: String?
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
