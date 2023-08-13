import Foundation

public struct FullAppVersion: Hashable, CustomStringConvertible {
    public let short: ShortAppVersion
    public let build: Int

    public init(short: ShortAppVersion, build: Int) {
        self.short = short
        self.build = build
    }

    public var description: String {
        "\(short)(\(build))"
    }
}
