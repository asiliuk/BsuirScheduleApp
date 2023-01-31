import SwiftUI
import ScheduleFeature
import BsuirUI
import ComposableArchitecture
import ComposableArchitectureUtils
import SwiftUINavigation

public struct LectorScheduleView: View {
    let store: StoreOf<LectorScheduleFeature>

    struct ViewState: Equatable {
        let groupScheduleName: String?

        init(state: LectorScheduleFeature.State) {
            self.groupScheduleName = state.groupSchedule?.groupName
        }
    }
    
    public init(store: StoreOf<LectorScheduleFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            ScheduleFeatureView(
                store: store.scope(state: \.schedule, reducerAction: { .schedule($0) }),
                schedulePairDetails: .groups {
                    viewStore.send(.groupTapped($0))
                }
            )
            .sheet(
                unwrapping: viewStore.binding(
                    get: \.groupScheduleName,
                    send: { .view(.setGroupScheduleName($0)) }
                )
            ) { _ in
                IfLetStore(
                    store.scope(
                        state: \.groupSchedule,
                        reducerAction: { .groupSchedule($0) }
                    )
                ) { store in
                    ModalNavigationStack {
                        GroupScheduleView(store: store)
                    }
                }
            }
        }
    }
}
