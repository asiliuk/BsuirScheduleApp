import Foundation
import ComposableArchitecture

extension Scope where ParentAction: FeatureAction {
    @inlinable
    public init<ChildState, ChildAction>(
        state toChildState: WritableKeyPath<ParentState, Child.State>,
        reducerAction toChildAction: CasePath<ParentAction.ReducerAction, Child.Action>,
        @ReducerBuilder<ChildState, ChildAction> child: () -> Child
    ) where ChildState == Child.State, ChildAction == Child.Action {
        self.init(
            state: toChildState,
            action: (/Action.reducer).appending(path: toChildAction),
            child: child
        )
    }
}
