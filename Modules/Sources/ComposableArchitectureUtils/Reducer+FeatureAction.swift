import Foundation
import ComposableArchitecture

extension ReducerProtocol where Action: FeatureAction {
    public func ifLet<Wrapped: ReducerProtocol>(
        _ toWrappedState: WritableKeyPath<State, Wrapped.State?>,
        reducerAction toWrappedAction: CasePath<Action.ReducerAction, Wrapped.Action>,
        @ReducerBuilderOf<Wrapped> then wrapped: () -> Wrapped,
        file: StaticString = #file,
        fileID: StaticString = #fileID,
        line: UInt = #line
    ) -> some ReducerProtocol<State, Action> {
        self.ifLet(
            toWrappedState,
            action: (/Action.reducer).appending(path: toWrappedAction),
            then: wrapped,
            file: file,
            fileID: fileID,
            line: line
        )
    }

    public func forEach<ID: Hashable, Element: ReducerProtocol>(
        _ toElementsState: WritableKeyPath<State, IdentifiedArray<ID, Element.State>>,
        reducerAction toElementAction: CasePath<Action.ReducerAction, (ID, Element.Action)>,
        @ReducerBuilderOf<Element> _ element: () -> Element,
        file: StaticString = #file,
        fileID: StaticString = #fileID,
        line: UInt = #line
    ) -> some ReducerProtocol<State, Action> {
        self.forEach(
            toElementsState,
            action: (/Action.reducer).appending(path: toElementAction),
            element,
            file: file,
            fileID: fileID,
            line: line
        )
    }
}
