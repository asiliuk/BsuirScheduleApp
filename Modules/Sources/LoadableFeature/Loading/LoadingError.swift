import Foundation
import URLRouting

public enum LoadingError: Error, Equatable, Hashable {
    case unknown
    case notConnectedToInternet
    case failedToDecode(url: URL?, description: String, response: Data)
    case somethingWrongWithBsuir(url: URL?, description: String)

    init(_ error: Error) {
        switch error {
        case let urlError as URLError:
            switch urlError.code {
            case .notConnectedToInternet, .timedOut, .networkConnectionLost:
                self = .notConnectedToInternet
            default:
                assertionFailure("Unknown url error code \(urlError.code)")
                self = .unknown
            }
        case let decodingError as URLRoutingDecodingError:
            let url = decodingError.response.url
            let description = String(describing: decodingError.underlyingError)

            switch (decodingError.response as? HTTPURLResponse)?.statusCode ?? 0 {
            case 200..<300:
                self = .failedToDecode(url: url, description: description, response: decodingError.bytes)
            default:
                self = .somethingWrongWithBsuir(url: url, description: description)
            }
        default:
            assertionFailure("Unknown error type \(error)")
            self = .unknown
        }
    }
}
