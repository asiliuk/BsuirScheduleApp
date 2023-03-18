import SwiftUI
import ScheduleFeature
import BsuirUI
import ComposableArchitecture
import ComposableArchitectureUtils
import SwiftUINavigation

public struct LectorScheduleView: View {
    let store: StoreOf<LectorScheduleFeature>

    public init(store: StoreOf<LectorScheduleFeature>) {
        self.store = store
    }
    
    public var body: some View {
        ScheduleFeatureView(
            store: store.scope(state: \.schedule, reducerAction: { .schedule($0) }),
            schedulePairDetails: .groups {
                ViewStore(store.stateless).send(.groupTapped($0))
            }
        )
        .sheet(
            store: store.scope(
                state: \.$groupSchedule,
                action: { .reducer(.groupSchedule($0)) }
            )
        ) { store in
            ModalNavigationStack {
                GroupScheduleView(store: store)
            }
        }
    }
}
