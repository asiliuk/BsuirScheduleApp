import Foundation
import Dependencies

extension DependencyValues {
    public var appInfo: AppInfo {
        get { self[AppInfoKey.self] }
        set { self[AppInfoKey.self] = newValue }
    }
}

private enum AppInfoKey: DependencyKey {
    static let liveValue = AppInfo(bundle: .main)
}
