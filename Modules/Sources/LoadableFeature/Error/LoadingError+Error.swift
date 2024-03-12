import Foundation
import BsuirApi

extension LoadingError.State {
    init(_ error: Error) {
        switch RequestError(error) {
        case .unknown:
            self = .unknown(.init())
        case .notConnectedToInternet:
            self = .notConnectedToInternet(.init())
        case .failedToDecode(let url, let description):
            self = .failedToDecode(.init(url: url, description: description))
        case .noSchedule:
            self = .noSchedule(.init())
        case .somethingWrongWithBsuir(let url, let description, let statusCode):
            self = .somethingWrongWithBsuir(.init(url: url, description: description, statusCode: statusCode))
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
