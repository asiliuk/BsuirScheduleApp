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
        @Shared var sharedNow: Date

        init(
            source: ScheduleSource,
            response: ScheduleRequestResponse,
            pairRowDetails: PairRowDetails?,
            scheduleDisplayType: ScheduleDisplayType = .continuous
        ) {
            self.response = response
            self.scheduleType = scheduleDisplayType
            self.source = source

            @Dependency(\.date.now) var now
            self._sharedNow = Shared(value: now)

            self.compact = DayScheduleFeature.State(
                schedule: response.schedule,
                startDate: response.startDate,
                endDate: response.endDate,
                sharedNow: _sharedNow
            )

            self.continuous = ContinuousScheduleFeature.State(
                schedule: response.schedule,
                startDate: response.startDate,
                endDate: response.endDate,
                pairRowDetails: pairRowDetails,
                sharedNow: _sharedNow
            )

            self.exams = ExamsScheduleFeature.State(
                exams: response.exams,
                startDate: response.startExamsDate,
                endDate: response.endExamsDate,
                pairRowDetails: pairRowDetails,
                sharedNow: _sharedNow
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
        case onAppear
        case day(DayScheduleFeature.Action)
        case continuous(ContinuousScheduleFeature.Action)
        case exams(ExamsScheduleFeature.Action)

        case subgroupPicker(SubgroupPickerFeature.Action)

        case binding(BindingAction<State>)
    }

    @Dependency(\.reviewRequestService) var reviewRequestService
    @Dependency(\.subgroupFilterService) var subgroupFilterService
    @Dependency(\.date.now) var now

    public var body: some ReducerOf<Self> {
        BindingReducer()
            .onChange(of: \.scheduleType) { _, _ in
                Reduce { _, _ in
                    .run { _ in await reviewRequestService.madeMeaningfulEvent(.scheduleModeSwitched) }
                }
            }

        Reduce { state, action in
            switch action {
            case .onAppear:
                // Update date representing `now` on every view appearance
                // So all UI elements that depend on it could be re-rendered
                // For example `Today` and `Yesterday` text and pairs filtered for passed days
                state.$sharedNow.withLock { $0 = now }
                return .none
            case .day, .continuous, .exams, .subgroupPicker, .binding:
                return .none
            }
        }
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
