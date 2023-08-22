import SwiftUI
import ScheduleFeature
import BsuirUI
import ComposableArchitecture

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
    }
}
