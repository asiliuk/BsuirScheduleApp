import Foundation

struct ShortAppVersion: Hashable {
    let major: Int
    let minor: Int
    let patch: Int

    var description: String {
        "\(major).\(minor).\(patch)"
    }
}

extension ShortAppVersion: CustomStringConvertible, ExpressibleByStringLiteral {
    init(_ version: String) {
        var components = Array(version.components(separatedBy: ".").reversed())
        assert(components.count == 3, "Expects version in format \"x.x.x\"")
        self.major = components.popLast().flatMap(Int.init) ?? 0
        self.minor = components.popLast().flatMap(Int.init) ?? 0
        self.patch = components.popLast().flatMap(Int.init) ?? 0
    }

    init(stringLiteral version: String) {
        self.init(version)
    }
}

extension ShortAppVersion: Codable {
    init(from decoder: Decoder) throws {
        try self.init(stringLiteral: String(from: decoder))
    }

    func encode(to encoder: Encoder) throws {
        try description.encode(to: encoder)
    }
}

struct FullAppVersion: Hashable, CustomStringConvertible {
    let short: ShortAppVersion
    let build: Int

    var description: String {
        "\(short)(\(build))"
    }
}
