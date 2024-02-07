import Foundation

extension LoadingAction.Action: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.onAppear, .onAppear), (.refresh, .refresh):
            return true
        case (.loadingError(let lhs), .loadingError(let rhs)):
            return lhs == rhs
        case (.delegate(let lhs), .delegate(let rhs)):
            return lhs == rhs
        case let (._loaded(_, lhsIsEqualTo), ._loaded(rhs, _)):
            return lhsIsEqualTo(rhs)
        case let (._loadingFailed(lhs), ._loadingFailed(rhs)):
            return (lhs as NSError) == (rhs as NSError)
        case (._loadingFailed, _), (._loaded, _), (.onAppear, _), (.refresh, _), (.loadingError, _), (.delegate, _):
            return false
        }
    }
}
