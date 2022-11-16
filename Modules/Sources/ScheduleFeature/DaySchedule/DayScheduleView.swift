import SwiftUI
import BsuirUI
import BsuirApi
import ComposableArchitecture
import ComposableArchitectureUtils

struct DayScheduleView: View {
    let store: StoreOf<DayScheduleFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            if viewStore.days.isEmpty {
                ScheduleEmptyView()
            } else {
                ScheduleGridView(
                    days: viewStore.days,
                    pairDetails: .nothing,
                    isOnTop: .constant(nil)
                )
                .task { await viewStore.send(.task).finish() }
            }
        }
    }
}

struct DayScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        DayScheduleView(
            store: .init(
                initialState: .init(schedule: DaySchedule(days: [
                    .monday: [
                        Pair(subject: "POIT"),
                        Pair(subject: "OSiSP")
                    ],
                    .sunday: [
                        Pair(subject: "POIT", weekNumber: .evenWeeks),
                        Pair(subject: "OSiSP", weekNumber: .oddWeeks)
                    ]
                ])),
                reducer: DayScheduleFeature()
            )
        )
    }
}
