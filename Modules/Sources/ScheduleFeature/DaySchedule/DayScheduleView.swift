import SwiftUI
import BsuirUI
import BsuirApi
import ComposableArchitecture
import ComposableArchitectureUtils

struct DayScheduleView: View {
    let store: StoreOf<DayScheduleReducer>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ScheduleGridView(
                days: viewStore.days,
                isOnTop: viewStore.binding(\.$isOnTop)
            )
            .onAppear { viewStore.send(.onAppear) }
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
                reducer: DayScheduleReducer()
            )
        )
    }
}
