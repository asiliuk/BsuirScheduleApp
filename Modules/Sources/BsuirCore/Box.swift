import Foundation

public final class Box<T> {
    public var value: T
    public init(_ value: T) { self.value = value }
}

extension Box: Equatable where T: Equatable {
    public static func == (lhs: Box, rhs: Box) -> Bool { lhs.value == rhs.value }
}

extension Box: Hashable where T: Hashable {
    public func hash(into hasher: inout Hasher) {
        value.hash(into: &hasher)
    }
}

extension Box: Identifiable where T: Identifiable {
    public var id: T.ID { value.id }
}
