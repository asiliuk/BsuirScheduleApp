import SwiftUI
import ComposableArchitecture

public struct EntityScheduleView: View {
    let state: EntityScheduleFeature.State

    public init(state: EntityScheduleFeature.State) {
        self.state = state
    }

    public var body: some View {
        switch state {
        case .group:
            CaseLet(
                /EntityScheduleFeature.State.group,
                 action: EntityScheduleFeature.Action.group,
                 then: GroupScheduleView.init
            )

        case .lector:
            CaseLet(
                /EntityScheduleFeature.State.lector,
                 action: EntityScheduleFeature.Action.lector,
                 then: LectorScheduleView.init
            )
        }
    }
}

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
