//
//  Unknownable.swift
//  
//
//  Created by Anton Siliuk on 12/10/19.
//

import Foundation

@propertyWrapper
public enum Unknownable<T: RawRepresentable> {
    case some(T)
    case unknown(T.RawValue)

    public var wrappedValue: T? {
        switch self {
        case let .some(value): return value
        case .unknown: return nil
        }
    }
}

extension Unknownable: Equatable where T: Equatable, T.RawValue: Equatable {}
extension Unknownable: Hashable where T: Hashable, T.RawValue: Hashable {}

extension Unknownable: Decodable where T.RawValue: Decodable {

    public init(from decoder: Decoder) throws {
        let value = try T.RawValue(from: decoder)
        self = T(rawValue: value).map(Unknownable.some) ?? .unknown(value)
    }
}

extension Unknownable: Encodable where T.RawValue: Encodable {

    public func encode(to encoder: Encoder) throws {
        switch self {
        case let .some(value):
            try value.rawValue.encode(to: encoder)
        case let .unknown(value):
            try value.encode(to: encoder)
        }
    }
}
