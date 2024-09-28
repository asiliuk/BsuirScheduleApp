import SwiftUI
import ComposableArchitecture

public struct EntityScheduleObservableView: View {
    let store: StoreOf<EntityScheduleFeature>

    public init(store: StoreOf<EntityScheduleFeature>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            switch store.state {
            case .group:
                if let store = store.scope(state: \.group, action: \.group) {
                    GroupScheduleView(store: store)
                }
                
            case .lector:
                if let store = store.scope(state: \.lector, action: \.lector) {
                    LectorScheduleView(store: store)
                }
            }
        }
    }
}
