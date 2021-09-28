//
//  Deeplink.swift
//  BsuirCore
//
//  Created by Anton Siliuk on 28.09.21.
//  Copyright © 2021 Saute. All rights reserved.
//

import Foundation

public enum Deeplink {
    case groups(id: Int?)
    case lecturers(id: Int?)
}

extension Deeplink: RawRepresentable {
    public init?(rawValue url: URL) {
        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
            components.host == Self.host
        else { return nil }

        let id = components.queryItems?
            .first { $0.name == "id" }
            .flatMap(\.value)
            .flatMap(Int.init)

        switch components.path {
        case "/groups":
            self = .groups(id: id)
        case "/lecturers":
            self = .lecturers(id: id)
        default:
            assertionFailure("Unexpected incoming URL \(url)")
            return nil
        }
    }

    public var rawValue: URL {
        var components = URLComponents()
        components.scheme = Self.scheme
        components.host = Self.host

        func queryItems(id: Int?) -> [URLQueryItem]? {
            guard let id = id else {
                return nil
            }

            return [URLQueryItem(name: "id", value: String(id)) ]
        }

        switch self {
        case let .groups(id):
            components.path = "/groups"
            components.queryItems = queryItems(id: id)
        case let .lecturers(id):
            components.path = "/lecturers"
            components.queryItems = queryItems(id: id)
        }

        guard let url = components.url else {
            assertionFailure("Failed to generate URL from \(components)")
            return URL(fileURLWithPath: "", isDirectory: false)
        }

        return url
    }

    private static let scheme = "bsuir-schedule"
    private static let host = "bsuirschedule.app"
}
