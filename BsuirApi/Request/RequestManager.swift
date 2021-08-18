//
//  RequestManager.swift
//  Pods
//
//  Created by Anton Siliuk on 13.09.17.
//
//

import Foundation
import os.log
import Combine

public struct RequestsManager {
    public let cache: URLCache

    private let base: String
    private let session: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let logger: Logger

    public init(
        base: String,
        session: URLSession,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder(),
        cache: URLCache
    ) {
        self.base = base
        self.session = session
        self.encoder = encoder
        self.decoder = decoder
        self.cache = cache
        self.logger = Logger(subsystem: "com.saute.Bsuir-Schedule", category: "RequestsManager")
    }

    public enum ConstructError: Error {
        case invalidBase(String)
        case cannotConstructUrl(from: URLComponents)
    }

    public func constructRequest<T: Target>(for target: T) -> Result<URLRequest, ConstructError> {

        guard var components = URLComponents(string: base) else { return .failure(.invalidBase(base)) }

        components.path.append(target.path)

        var body: Data?
        switch target.method {
        case .get where !target.parameters.isEmpty:
            components.queryItems = target.parameters.map { URLQueryItem(name: $0, value: $1) }
        case .post:
            body = try? encoder.encode(target.parameters)
        case .get:
            break
        }

        guard let url = components.url else { return .failure(.cannotConstructUrl(from: components)) }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept-Encoding")
        request.httpMethod = target.method.rawValue
        request.httpBody = body

        defer { logger.debug("\(request.curlDescription)") }

        return .success(request)
    }

    public enum DataRequestError: Error {
        case invalidRequest(ConstructError)
        case responseError(URLError)
    }

    public func dataRequest<T: Target>(for target: T, checkCache: Bool = true) -> AnyPublisher<(data: Data, response: URLResponse), DataRequestError> {
        return Deferred {
            return constructRequest(for: target)
                .publisher
                .mapError(DataRequestError.invalidRequest)
                .flatMap { request -> AnyPublisher<(data: Data, response: URLResponse), DataRequestError> in
                    let remoteData = cachingDataTaskPublisher(for: request)
                        .mapError(DataRequestError.responseError)

                    guard
                        checkCache,
                        let cached = cache.cachedResponse(for: request)
                    else {
                        return remoteData.eraseToAnyPublisher()
                    }

                    return Just((data: cached.data, response: cached.response))
                        .setFailureType(to: DataRequestError.self)
                        .append(remoteData)
                        .eraseToAnyPublisher()
                }
        }
        .removeDuplicates(by: ==)
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }

    private func cachingDataTaskPublisher(for request: URLRequest) -> Publishers.HandleEvents<URLSession.DataTaskPublisher> {
        return session
            .dataTaskPublisher(for: request)
            .handleEvents(receiveOutput: { output in
                cache.storeCachedResponse(
                    CachedURLResponse(response: output.response, data: output.data),
                    for: request
                )
            })
    }

    public enum RequestError: Error {
        case dataRequestError(DataRequestError)
        case decodeError(Error)
    }

    public func request<T: Target>(_ target: T, checkCache: Bool = true) -> AnyPublisher<T.Value, RequestError> {
        return Deferred {
            dataRequest(for: target, checkCache: checkCache)
                .mapError(RequestError.dataRequestError)
                .flatMap { value in
                    Result { try decoder.decode(T.Value.self, from: value.data) }
                        .publisher
                        .mapError(RequestError.decodeError)
                }
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
}

private extension URLRequest {
    var curlDescription: String {
        guard let url = url else { return "[Unknown]" }

        let body = httpBody
            .flatMap { String(data: $0, encoding: .utf8) }
            .map { "-d '\($0)'" }

        let headers = allHTTPHeaderFields?
            .map { "-H '\($0.0): \($0.1)'" }

        let components = ["curl", url.absoluteString] + ([body].compactMap { $0 }) + (headers ?? [])

        return components.joined(separator: " ")
    }
}
