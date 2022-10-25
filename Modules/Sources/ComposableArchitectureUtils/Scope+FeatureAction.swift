import Foundation
import ComposableArchitecture

extension Scope where ParentAction: FeatureAction {
    @inlinable
    public init(
        state toChildState: WritableKeyPath<ParentState, Child.State>,
        action toChildAction: CasePath<ParentAction.ReducerAction, Child.Action>,
        @ReducerBuilderOf<Child> _ child: () -> Child
    ) {
        self.init(
            state: toChildState,
            action: (/Action.reducer).appending(path: toChildAction),
            child
        )
    }
}
