import Foundation
import ComposableArchitecture

extension Reducer where Action: FeatureAction {
    public func ifLet<WrappedState, WrappedAction, Wrapped: Reducer>(
        _ toWrappedState: WritableKeyPath<State, Wrapped.State?>,
        reducerAction toWrappedAction: CasePath<Action.ReducerAction, Wrapped.Action>,
        @ReducerBuilder<WrappedState, WrappedAction> then wrapped: () -> Wrapped,
        file: StaticString = #file,
        fileID: StaticString = #fileID,
        line: UInt = #line
    ) -> some Reducer<State, Action>
    where WrappedState == Wrapped.State, WrappedAction == Wrapped.Action {
        self.ifLet(
            toWrappedState,
            action: (/Action.reducer).appending(path: toWrappedAction),
            then: wrapped,
            file: file,
            fileID: fileID,
            line: line
        )
    }

    public func forEach<ElementState, ElementAction, ID: Hashable, Element: Reducer>(
        _ toElementsState: WritableKeyPath<State, IdentifiedArray<ID, Element.State>>,
        reducerAction toElementAction: CasePath<Action.ReducerAction, (ID, Element.Action)>,
        @ReducerBuilder<ElementState, ElementAction> element: () -> Element,
        file: StaticString = #file,
        fileID: StaticString = #fileID,
        line: UInt = #line
    ) -> some Reducer<State, Action>
    where ElementState == Element.State, ElementAction == Element.Action {
        self.forEach(
            toElementsState,
            action: (/Action.reducer).appending(path: toElementAction),
            element: element,
            file: file,
            fileID: fileID,
            line: line
        )
    }
}
