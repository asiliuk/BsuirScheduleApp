import SwiftUI
import ScheduleFeature
import BsuirUI
import ComposableArchitecture
import ComposableArchitectureUtils
import SwiftUINavigation

public struct GroupScheduleView: View {
    let store: StoreOf<GroupScheduleFeature>
    
    public init(store: StoreOf<GroupScheduleFeature>) {
        self.store = store
    }
    
    public var body: some View {
        ScheduleFeatureView(
            store: store.scope(state: \.schedule, action: { .schedule($0) }),
            schedulePairDetails: .lecturers {
                ViewStore(store.stateless).send(.lectorTapped($0))
            }
        )
        .sheet(
            store: store.scope(
                state: \.$lectorSchedule,
                action: { .lectorSchedule($0) }
            )
        ) { store in
            ModalNavigationStack {
                LectorScheduleView(store: store)
            }
        }
    }
}
