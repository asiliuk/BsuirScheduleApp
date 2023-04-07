import SwiftUI
import ScheduleFeature
import BsuirUI
import ComposableArchitecture
import SwiftUINavigation

public struct LectorScheduleView: View {
    let store: StoreOf<LectorScheduleFeature>

    public init(store: StoreOf<LectorScheduleFeature>) {
        self.store = store
    }
    
    public var body: some View {
        ScheduleFeatureView(
            store: store.scope(state: \.schedule, action: { .schedule($0) }),
            schedulePairDetails: .groups {
                ViewStore(store.stateless).send(.groupTapped($0))
            }
        )
        .sheet(
            store: store.scope(
                state: \.$groupSchedule,
                action: { .groupSchedule($0) }
            )
        ) { store in
            ModalNavigationStack {
                GroupScheduleView(store: store)
            }
        }
    }
}
