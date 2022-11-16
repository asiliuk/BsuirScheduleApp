import Foundation
import BsuirCore
import BsuirApi
import ScheduleFeature
import ComposableArchitecture
import ComposableArchitectureUtils

public struct GroupScheduleFeature: ReducerProtocol {
    public struct State: Equatable, Identifiable {
        public var id: String { schedule.value }
        public var schedule: ScheduleFeature<String>.State
        
        // Has to be wrapped in the box or fails to compile because
        // of recursive state between group & lector schedule states
        @BindableState var lectorSchedule: Box<LectorScheduleFeature.State>?
        
        public init(groupName: String) {
            self.schedule = .init(title: groupName, value: groupName)
        }
    }
    
    public enum Action: Equatable, FeatureAction, BindableAction {
        public enum ViewAction: Equatable {
            case lectorTapped(Employee)
        }
        
        public enum ReducerAction: Equatable {
            case schedule(ScheduleFeature<String>.Action)
            indirect case lectorSchedule(LectorScheduleFeature.Action)
        }
        
        public typealias DelegateAction = Never

        case binding(BindingAction<State>)
        case view(ViewAction)
        case reducer(ReducerAction)
        case delegate(DelegateAction)
    }

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case let .view(.lectorTapped(lector)):
                state.lectorSchedule = .init(.init(lector: lector))
                return .none
            case .reducer, .binding:
                return .none
            }
        }
        .ifLet(\.lectorSchedule, action: (/Action.reducer).appending(path: /Action.ReducerAction.lectorSchedule)) {
            Scope(state: \.value, action: .self) {
                LectorScheduleFeature()
            }
        }
        
        Scope(state: \.schedule, action: /Action.ReducerAction.schedule) {
            ScheduleFeature(
                target: { BsuirIISTargets.GroupSchedule(groupNumber: $0) },
                schedule: { ($0.schedules, $0.examSchedules) }
            )
        }
        
        BindingReducer()
    }
}
