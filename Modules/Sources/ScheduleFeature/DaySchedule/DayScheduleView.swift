import SwiftUI
import BsuirUI
import BsuirApi
import ComposableArchitecture

struct DayScheduleView: View {
    let store: StoreOf<DayScheduleFeature>

    var body: some View {
        ScheduleListView(
            store: store.scope(
                state: \.scheduleList,
                action: \.scheduleList
            )
        )
    }
}

struct DayScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        let initialState = DayScheduleFeature.State(schedule: DaySchedule(days: [
            .monday: [
                Pair(subject: "POIT"),
                Pair(subject: "OSiSP")
            ],
            .sunday: [
                Pair(subject: "POIT", weekNumber: .evenWeeks),
                Pair(subject: "OSiSP", weekNumber: .oddWeeks)
            ]
        ]))

        DayScheduleView(
            store: Store(initialState: initialState) {
                DayScheduleFeature()
            }
        )
    }
}
