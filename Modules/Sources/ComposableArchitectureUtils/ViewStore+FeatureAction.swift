import SwiftUI
import ComposableArchitecture

extension ViewStore where ViewAction: FeatureAction {
    @discardableResult
    public func send(_ action: ViewAction.ViewAction, animation: Animation?) -> ViewStoreTask {
        send(.view(action), animation: animation)
    }
    
    @discardableResult
    public func send(_ action: ViewAction.ViewAction) -> ViewStoreTask {
        send(.view(action))
    }
}
