import Foundation

public struct ShortAppVersion: Hashable {
    public let major: Int
    public let minor: Int
    public let patch: Int

    public var description: String {
        "\(major).\(minor).\(patch)"
    }
}

// MARK: - String

extension ShortAppVersion: CustomStringConvertible, ExpressibleByStringLiteral {
    public init(_ version: String) {
        var components = Array(version.components(separatedBy: ".").reversed())
        assert(components.count == 3, "Expects version in format \"x.x.x\"")
        self.major = components.popLast().flatMap(Int.init) ?? 0
        self.minor = components.popLast().flatMap(Int.init) ?? 0
        self.patch = components.popLast().flatMap(Int.init) ?? 0
    }

    public init(stringLiteral version: String) {
        self.init(version)
    }
}

// MARK: - Codable

extension ShortAppVersion: Codable {
    public init(from decoder: Decoder) throws {
        try self.init(stringLiteral: String(from: decoder))
    }

    public func encode(to encoder: Encoder) throws {
        try description.encode(to: encoder)
    }
}
