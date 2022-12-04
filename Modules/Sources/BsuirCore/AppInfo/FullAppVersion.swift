import Foundation

public struct FullAppVersion: Hashable, CustomStringConvertible {
    public let short: ShortAppVersion
    public let build: Int

    public var description: String {
        "\(short)(\(build))"
    }
}
