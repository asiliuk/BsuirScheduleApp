import Foundation

public enum RequestError: Error {
    case unknown(Error)
    case notConnectedToInternet
    case failedToDecode(url: URL?, description: String)
    case noSchedule
    case somethingWrongWithBsuir(url: URL?, description: String, statusCode: Int)

    public init(_ error: Error) {
        switch error {
        case let urlError as URLError:
            switch urlError.code {
            case .notConnectedToInternet, .timedOut, .networkConnectionLost, .dataNotAllowed:
                self = .notConnectedToInternet
            default:
                assertionFailure("Unknown url error code \(urlError.code)")
                self = .unknown(error)
            }
        case let decodingError as MyURLRoutingDecodingError:
            let url = decodingError.response.url
            let description = String(describing: decodingError.underlyingError)

            switch (decodingError.response as? HTTPURLResponse)?.statusCode ?? 0 {
            case 200..<300:
                self = .failedToDecode(url: url, description: description)
            case 404:
                self = .noSchedule
            case let statusCode:
                self = .somethingWrongWithBsuir(url: url, description: description, statusCode: statusCode)
            }
        default:
            assertionFailure("Unknown error type \(error)")
            self = .unknown(error)
        }
    }
}
