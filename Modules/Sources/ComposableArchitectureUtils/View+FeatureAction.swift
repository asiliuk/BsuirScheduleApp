import SwiftUI
import ComposableArchitecture

extension View {
    @ViewBuilder public func alert<Action: FeatureAction>(
        _ store: Store<AlertState<Action>?, Action>,
        dismiss: Action.ViewAction
    ) -> some View {
        alert(store, dismiss: .view(dismiss))
    }
}
