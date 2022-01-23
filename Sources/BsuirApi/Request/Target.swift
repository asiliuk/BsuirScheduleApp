//
//  Target.swift
//  Pods
//
//  Created by Anton Siliuk on 13.09.17.
//
//

import Foundation

public enum HTTPMethod : String {
    case get = "GET"
    case post = "POST"
}

public protocol Target {

    associatedtype Value: Decodable

    var path: String { get }
    var method: HTTPMethod { get }

    var parameters: [String: String] { get }
}

extension Target {

    public var method: HTTPMethod { .get }
    public var parameters: [String: String] { [:] }
}
