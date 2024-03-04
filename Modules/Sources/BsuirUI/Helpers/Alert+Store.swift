// Copied from https://github.com/pointfreeco/swift-composable-architecture/discussions/2816
import ComposableArchitecture
import SwiftUI

extension View {
    /// Presents an alert when a piece of optional state held in a store becomes non-`nil`.
    public func alert<State, Action, Actions: View, Message: View>(
        _ item: Binding<Store<State, Action>?>,
        title: (Store<State, Action>) -> LocalizedStringKey,
        @ViewBuilder actions: (Store<State, Action>) -> Actions,
        @ViewBuilder message: (Store<State, Action>) -> Message
    ) -> some View {
        let store = item.wrappedValue
        return alert(
            store.map { store in title(store) } ?? "",
            isPresented: item.isPresent(),
            presenting: store,
            actions: { store in
                actions(store)
            },
            message: { store in
                message(store)
            }
        )
    }

    public func alert<State, Action, Actions: View, Message: View>(
        _ item: Binding<Store<State, Action>?>,
        title: LocalizedStringKey,
        @ViewBuilder actions: (Store<State, Action>) -> Actions,
        @ViewBuilder message: (Store<State, Action>) -> Message
    ) -> some View {
        alert(item, title: { _ in title }, actions: actions, message: message)
    }
}

extension Binding {
    /// Creates a binding by projecting the current optional value to a boolean describing if it's
    /// non-`nil`.
    ///
    /// Writing `false` to the binding will `nil` out the base value. Writing `true` does nothing.
    ///
    /// - Returns: A binding to a boolean. Returns `true` if non-`nil`, otherwise `false`.
    public func isPresent<Wrapped>() -> Binding<Bool>
    where Value == Wrapped? {
        .init(
            get: { self.wrappedValue != nil },
            set: { isPresent, transaction in
                if !isPresent {
                    self.transaction(transaction).wrappedValue = nil
                }
            }
        )
    }
}
