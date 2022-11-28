import Foundation

public enum LoadingError: Error, Equatable {
    case unknown
    case notConnectedToInternet
    case parsing

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
        default:
            assertionFailure("Unknown error type \(error)")
            self = .unknown
        }
    }
}
