import Foundation
import ComposableArchitecture
import Algorithms
import BsuirApi
import BsuirCore
import ScheduleCore

@Reducer
public struct LoadedScheduleReducer {
    @ObservableState
    public struct State {
        var response: ScheduleRequestResponse
        var scheduleType: ScheduleDisplayType

        var compact: DayScheduleFeature.State
        var continuous: ContinuousScheduleFeature.State
        var exams: ExamsScheduleFeature.State

        var subgroupPicker: SubgroupPickerFeature.State?
        fileprivate var source: ScheduleSource

        init(
            source: ScheduleSource,
            response: ScheduleRequestResponse,
            pairRowDetails: PairRowDetails?,
            scheduleDisplayType: ScheduleDisplayType = .continuous
        ) {
            self.response = response
            self.scheduleType = scheduleDisplayType
            self.source = source

            self.compact = DayScheduleFeature.State(
                schedule: response.schedule,
                startDate: response.startDate,
                endDate: response.endDate
            )

            self.continuous = ContinuousScheduleFeature.State(
                schedule: response.schedule,
                startDate: response.startDate,
                endDate: response.endDate,
                pairRowDetails: pairRowDetails
            )

            self.exams = ExamsScheduleFeature.State(
                exams: response.exams,
                startDate: response.startExamsDate,
                endDate: response.endExamsDate,
                pairRowDetails: pairRowDetails
            )

            let allSchedulePairs = DaySchedule.WeekDay.allCases
                .lazy
                .compactMap { response.schedule[$0] }
                .flatMap { $0 }

            let allPairs = chain(allSchedulePairs, response.exams)

            let maxSubgroup = allPairs.lazy
                .map(\.subgroup)
                .filter { $0 != 0 }
                .max()

            @Dependency(\.subgroupFilterService) var subgroupFilterService
            if let maxSubgroup {
                let savedSubgroupSelection = subgroupFilterService.preferredSubgroup(source).value
                subgroupPicker = SubgroupPickerFeature.State(
                    maxSubgroup: maxSubgroup,
                    selected: savedSubgroupSelection
                )
            }

            if continuous.hasSchedule == false, scheduleDisplayType == .continuous {
                // Switch to exams if no regular schedule available
                scheduleType = .exams
            }
        }
    }

    public enum Action: BindableAction {
        case day(DayScheduleFeature.Action)
        case continuous(ContinuousScheduleFeature.Action)
        case exams(ExamsScheduleFeature.Action)

        case subgroupPicker(SubgroupPickerFeature.Action)

        case binding(BindingAction<State>)
    }

    @Dependency(\.reviewRequestService) var reviewRequestService
    @Dependency(\.subgroupFilterService) var subgroupFilterService

    public var body: some ReducerOf<Self> {
        BindingReducer()
            .onChange(of: \.scheduleType) { _, _ in
                Reduce { _, _ in
                    .run { _ in await reviewRequestService.madeMeaningfulEvent(.scheduleModeSwitched) }
                }
            }

        EmptyReducer()
            .ifLet(\.subgroupPicker, action: \.subgroupPicker) {
                SubgroupPickerFeature()
            }
            .onChange(of: \.subgroupPicker?.selected) { _, newValue in
                Reduce { state, _ in
                    .run { [source = state.source] _ in
                        subgroupFilterService.preferredSubgroup(source).value = newValue
                    }
                }
            }

        Scope(state: \.compact, action: \.day) {
            DayScheduleFeature()
        }

        Scope(state: \.continuous, action: \.continuous) {
            ContinuousScheduleFeature()
        }

        Scope(state: \.exams, action: \.exams) {
            ExamsScheduleFeature()
        }
    }
}

private extension MeaningfulEvent {
    static let scheduleModeSwitched = Self(score: 3)
}
