import Foundation
import ComposableArchitecture
import BsuirCore
import ScheduleCore
public import Combine

@Reducer
struct PinnedFeature {
    @ObservableState
    struct State {
        @SharedReader(.isPremiumUser) var isPremiumUser
        var schedule: ScheduleFeature.State?

        init() {
            @Dependency(\.pinnedScheduleService.currentSchedule) var pinnedSchedule
            schedule = pinnedSchedule().map { ScheduleFeature.State(source: $0) }
        }
    }

    enum Action {
        case task
        case setPinnedSchedule(ScheduleSource?)
        case schedule(ScheduleFeature.Action)
    }

    @Dependency(\.pinnedScheduleService.schedule) var pinnedSchedule

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .task:
                return .run { [pinnedSchedule] send in
                    for await source in pinnedSchedule().values {
                        await send(.setPinnedSchedule(source))
                    }
                }
            case .setPinnedSchedule(let source):
                state.schedule = source.map { ScheduleFeature.State(source: $0) }
                return .none
            case .schedule:
                return .none
            }
        }
        .ifLet(\.schedule, action: \.schedule) {
            ScheduleFeature()
        }
    }
}
