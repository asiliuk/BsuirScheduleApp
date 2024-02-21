import Foundation
import BsuirApi

extension LoadingError.State {
    init(_ error: Error) {
        switch error {
        case let urlError as URLError:
            switch urlError.code {
            case .notConnectedToInternet, .timedOut, .networkConnectionLost, .dataNotAllowed:
                self = .notConnectedToInternet(.init())
            default:
                assertionFailure("Unknown url error code \(urlError.code)")
                self = .unknown(.init())
            }
        case let decodingError as MyURLRoutingDecodingError:
            let url = decodingError.response.url
            let description = String(describing: decodingError.underlyingError)

            switch (decodingError.response as? HTTPURLResponse)?.statusCode ?? 0 {
            case 200..<300:
                self = .failedToDecode(.init(url: url, description: description))
            case 404:
                self = .noSchedule(.init())
            case let statusCode:
                self = .somethingWrongWithBsuir(.init(url: url, description: description, statusCode: statusCode))
            }
        default:
            assertionFailure("Unknown error type \(error)")
            self = .unknown(.init())
        }
    }
}

extension LoadingError.Action {
    var isReload: Bool {
        switch self {
        case .somethingWrongWithBsuir(.reloadButtonTapped),
             .notConnectedToInternet(.reloadButtonTapped),
             .noSchedule(.reloadButtonTapped),
             .unknown(.reloadButtonTapped):
            return true
        case .failedToDecode,
             .somethingWrongWithBsuir(.reachability),
             .somethingWrongWithBsuir(.openIssueTapped):
            return false
        }
    }
}
