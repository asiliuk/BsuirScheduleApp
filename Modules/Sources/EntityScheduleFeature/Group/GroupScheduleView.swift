import SwiftUI
import ScheduleFeature
import BsuirUI
import ComposableArchitecture
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
                store.send(.lectorTapped($0))
            }
        )
        .navigationDestination(
            store: store.scope(
                state: \.$lectorSchedule,
                action: { .lectorSchedule($0) }
            ),
            destination: LectorScheduleView.init
        )
    }
}
