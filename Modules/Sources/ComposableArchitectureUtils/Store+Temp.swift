import ComposableArchitecture

extension Store {
    public func tempViewStore() -> ViewStore<Void, Action> {
        ViewStore(self.scope(state: { _ in }))
    }
}
