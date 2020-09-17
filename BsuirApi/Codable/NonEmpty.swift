//
//  NonEmpty.swift
//  
//
//  Created by Anton Siliuk on 12/10/19.
//

import Foundation

@propertyWrapper
public struct NonEmpty<T> : Codable where T: RangeReplaceableCollection, T: Codable {

    public let wrappedValue: T
    public init(wrappedValue: T) { self.wrappedValue = wrappedValue }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        guard !container.decodeNil() else { self = .empty; return }
        self.init(wrappedValue: try container.decode(T.self))
    }

    public func encode(to encoder: Encoder) throws {
        try wrappedValue.encode(to: encoder)
    }

    fileprivate static var empty: NonEmpty { NonEmpty(wrappedValue: T()) }
}

extension NonEmpty: Hashable where T: Hashable {}
extension NonEmpty: Equatable where T: Equatable {}

extension KeyedDecodingContainer {

    public func decode<T>(_ type: NonEmpty<T>.Type, forKey key: Key) throws -> NonEmpty<T> {
        guard contains(key) else { return .empty }
        guard try !decodeNil(forKey: key) else { return .empty }
        return try NonEmpty(wrappedValue: decode(T.self, forKey: key))
    }
}
