import SwiftUI
import BsuirUI
import BsuirApi
import ComposableArchitecture
import ComposableArchitectureUtils

struct ExamsScheduleView: View {
    let store: StoreOf<ExamsScheduleFeature>
    let pairDetails: ScheduleGridViewPairDetails

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            if viewStore.days.isEmpty {
                ScheduleEmptyView()
                    .onAppear { viewStore.send(.onAppear) }
            } else {
                ScheduleGridView(
                    days: viewStore.days,
                    loading: .never,
                    pairDetails: pairDetails,
                    isOnTop: .constant(false)
                )
                .onAppear { viewStore.send(.onAppear) }
            }
        }
    }
}
