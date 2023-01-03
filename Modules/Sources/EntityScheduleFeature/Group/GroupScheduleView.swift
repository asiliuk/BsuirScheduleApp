import SwiftUI
import ScheduleFeature
import ComposableArchitecture
import ComposableArchitectureUtils
import SwiftUINavigation

public struct GroupScheduleView: View {
    let store: StoreOf<GroupScheduleFeature>

    struct ViewStore: Equatable {
        let lectorScheduleId: Int?

        init(state: GroupScheduleFeature.State) {
            self.lectorScheduleId = state.lectorSchedule?.value.lector.id
        }
    }
    
    public init(store: StoreOf<GroupScheduleFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: ViewStore.init) { viewStore in
            ScheduleFeatureView(
                store: store.scope(state: \.schedule, reducerAction: { .schedule($0) }),
                schedulePairDetails: .lecturers {
                    viewStore.send(.lectorTapped($0))
                }
            )
            .sheet(
                unwrapping: viewStore.binding(
                    get: \.lectorScheduleId,
                    send: { .view(.setLectorScheduleId($0)) }
                )
            ) { _ in
                IfLetStore(
                    store.scope(
                        state: \.lectorSchedule?.value,
                        reducerAction: { .lectorSchedule($0) }
                    )
                ) { store in
                    ModalNavigationStack {
                        LectorScheduleView(store: store)
                    }
                }
            }
        }
    }
}
