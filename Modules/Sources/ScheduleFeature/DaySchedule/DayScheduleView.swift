import SwiftUI
import BsuirUI
import BsuirApi
import ComposableArchitecture
import ComposableArchitectureUtils

struct DayScheduleView: View {
    let store: StoreOf<DayScheduleFeature>

    var body: some View {
        WithViewStore(store, observe: \.days) { viewStore in
            switch viewStore.state {
            case []:
                ScheduleEmptyView()
            case let days:
                ScheduleGridView(
                    days: days,
                    loading: .never,
                    pairDetails: .nothing,
                    isOnTop: .constant(false)
                )
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
