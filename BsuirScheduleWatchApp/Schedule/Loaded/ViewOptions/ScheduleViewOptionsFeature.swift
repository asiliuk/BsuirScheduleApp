import ComposableArchitecture
import ScheduleCore
import BsuirCore

@Reducer
struct ScheduleViewOptionsFeature {
    @ObservableState
    struct State {
        var displayType: ScheduleDisplayType
        var subgroup: ScheduleSubgroupFeature.State?

        init(
            source: ScheduleSource,
            hasSchedule: Bool,
            hasExams: Bool,
            maxSubgroup: Int?
        ) {
            self.displayType = !hasSchedule && hasExams ? .exams : .continuous
            self.subgroup = ScheduleSubgroupFeature.State(
                source: source,
                maxSubgroup: maxSubgroup
            )
        }
    }

    enum Action: BindableAction {
        case subgroup(ScheduleSubgroupFeature.Action)
        case binding(BindingAction<State>)
    }

    var body: some Reducer<State, Action> {
        BindingReducer()
            .ifLet(\.subgroup, action: \.subgroup) {
                ScheduleSubgroupFeature()
            }
    }
}

@Reducer
struct ScheduleSubgroupFeature {
    @ObservableState
    struct State {
        let source: ScheduleSource
        var selected: Int?
        var max: Int

        init?(source: ScheduleSource, maxSubgroup: Int?) {
            guard let maxSubgroup else { return nil }
            self.source = source
            @Dependency(\.subgroupFilterService) var subgroupFilterService
            self.selected = subgroupFilterService.preferredSubgroup(source).value
            self.max = maxSubgroup
        }
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
    }

    @Dependency(\.subgroupFilterService) var subgroupFilterService

    var body: some Reducer<State, Action> {
        BindingReducer()
            .onChange(of: \.selected, { oldValue, state in
                .run { [subgroupFilterService, source = state.source, newValue = state.selected] _ in
                    subgroupFilterService.preferredSubgroup(source).value = newValue
                }
            })
    }
}
