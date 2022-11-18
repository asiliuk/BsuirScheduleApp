import SwiftUI
import ScheduleFeature
import ComposableArchitecture
import ComposableArchitectureUtils

public struct LectorScheduleView: View {
    let store: StoreOf<LectorScheduleFeature>
    
    public init(store: StoreOf<LectorScheduleFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            ScheduleFeatureView(
                store: store.scope(state: \.schedule, action: { .schedule($0) }),
                continiousSchedulePairDetails: .groups {
                    viewStore.send(.groupTapped($0))
                }
            )
            .sheet(item: viewStore.binding(\.$groupSchedule)) { _ in
                ModalNavigationView {
                    IfLetStore(
                        store.scope(state: \.groupSchedule, action: { .groupSchedule($0) })
                    ) { store in
                        GroupScheduleView(store: store)
                    }
                }
            }
            .task { await viewStore.send(.task).finish() }
        }
    }
}
