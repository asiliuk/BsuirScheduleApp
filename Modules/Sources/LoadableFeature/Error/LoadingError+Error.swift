import Foundation
import BsuirApi

extension LoadingError.State {
    init(_ error: Error) {
        switch error {
        case let urlError as URLError:
            switch urlError.code {
            case .notConnectedToInternet, .timedOut, .networkConnectionLost, .dataNotAllowed:
                self = .notConnectedToInternet
            default:
                assertionFailure("Unknown url error code \(urlError.code)")
                self = .unknown
            }
        case let decodingError as MyURLRoutingDecodingError:
            let url = decodingError.response.url
            let description = String(describing: decodingError.underlyingError)

            switch (decodingError.response as? HTTPURLResponse)?.statusCode ?? 0 {
            case 200..<300:
                self = .failedToDecode(.init(url: url, description: description))
            case 404:
                self = .noSchedule
            case let statusCode:
                self = .somethingWrongWithBsuir(.init(url: url, description: description, statusCode: statusCode))
            }
        default:
            assertionFailure("Unknown error type \(error)")
            self = .unknown
        }
    }
}
