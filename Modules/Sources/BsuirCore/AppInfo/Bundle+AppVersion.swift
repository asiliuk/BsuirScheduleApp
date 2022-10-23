import Foundation

extension Bundle {
    public var fullVersion: FullAppVersion {
        FullAppVersion(short: shortVersion, build: buildNumber)
    }

    public var shortVersion: ShortAppVersion {
        ShortAppVersion(infoDictionary?["CFBundleShortVersionString"] as? String ?? "")
    }

    public var buildNumber: Int {
        Int(infoDictionary?["CFBundleVersion"] as? String ?? "") ?? 0
    }
}
