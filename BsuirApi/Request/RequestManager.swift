//
//  RequestManager.swift
//  Pods
//
//  Created by Anton Siliuk on 13.09.17.
//
//

import Foundation

public struct RequestsManager {

    public struct Logger {
        public let constructRequest: (URLRequest) -> Void
        public let dataRequest: (Data?, URLResponse?, Error?) -> Void
        public let request: (Any) -> Void

        public init(
            constructRequest: @escaping (URLRequest) -> Void = { _ in },
            dataRequest: @escaping (Data?, URLResponse?, Error?) -> Void = { _, _, _ in },
            request: @escaping (Any) -> Void = { _ in }
        ) {
            self.constructRequest = constructRequest
            self.dataRequest = dataRequest
            self.request = request
        }

        public static let dumper = Logger(constructRequest: { dump($0) }, dataRequest: { dump(($0, $1, $2)) }, request: { dump($0) })
    }

    public let base: String
    public let session: URLSession
    public let encoder: JSONEncoder
    public let decoder: JSONDecoder
    public let logger: Logger?

    public init(base: String, session: URLSession, encoder: JSONEncoder = JSONEncoder(), decoder: JSONDecoder = JSONDecoder(), logger: Logger? = nil) {
        self.base = base
        self.session = session
        self.encoder = encoder
        self.decoder = decoder
        self.logger = logger
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

        defer { logger?.constructRequest(request) }

        return .success(request)
    }

    public enum DataRequestError: Error {
        case invalidRequest(ConstructError)
        case responseError(Error)
        case unexpectedResponse
    }

    public func dataRequest<T: Target>(for target: T, completion: @escaping (Result<(Data, URLResponse), DataRequestError>) -> Void) {
        switch constructRequest(for: target) {
        case let .success(request):
            session.dataTask(with: request) { [logger] (data, response, error) in
                logger?.dataRequest(data, response, error)
                if let error = error { return completion(.failure(.responseError(error))) }
                if let data = data, let response = response { return completion(.success((data, response))) }
                completion(.failure(.unexpectedResponse))
            }.resume()
        case let .failure(error):
            completion(.failure(.invalidRequest(error)))
        }
    }

    public enum RequestError: Error {
        case dataRequestError(DataRequestError)
        case decodeError(Error)
    }

    public func request<T: Target>(_ target: T, completion: @escaping (Result<T.Value, RequestError>) -> Void) {
        dataRequest(for: target) { [logger, decoder] result in
            switch result {
            case let .success((data, _)):
                do {
                    let value = try decoder.decode(T.Value.self, from: data)
                    logger?.request(value)
                    completion(.success(value))
                } catch {
                    completion(.failure(.decodeError(error)))
                }
            case let .failure(error):
                completion(.failure(.dataRequestError(error)))
            }
        }
    }
}
