import PremiumClubFeature
import EntityScheduleFeature
import ScheduleCore
import ComposableArchitecture

public struct PinnedTabFeature: Reducer {
    public struct State: Equatable {
        var isPremiumLocked: Bool
        var schedule: EntityScheduleFeature.State?
        var path = StackState<EntityScheduleFeature.State>()
    }

    public enum Action: Equatable {
        public enum Delegate: Equatable {
            case showPremiumClubPinned
        }

        case schedule(EntityScheduleFeature.Action)
        case path(StackAction<EntityScheduleFeature.State, EntityScheduleFeature.Action>)
        case learnAboutPremiumClubTapped
        case delegate(Delegate)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .learnAboutPremiumClubTapped:
                return .send(.delegate(.showPremiumClubPinned))

            case .schedule(.delegate(let action)), .path(.element(_, .delegate(let action))):
                switch action {
                case .showPremiumClubPinned:
                    return .send(.delegate(.showPremiumClubPinned))
                case .showGroupSchedule(let name):
                    state.path.append(.group(.init(groupName: name)))
                    return .none
                case .showLectorSchedule(let lector):
                    state.path.append(.lector(.init(lector: lector)))
                    return .none
                }

            case .schedule, .delegate, .path:
                return .none
            }
        }
        .ifLet(\.schedule, action: /Action.schedule) {
            EntityScheduleFeature()
        }
        .forEach(\.path, action: /Action.path) {
            EntityScheduleFeature()
        }
    }
}

// MARK: - Selection

extension PinnedTabFeature.State {
    mutating func show(pinned pinnedSchedule: ScheduleSource) {
        switch pinnedSchedule {
        case .group(let name):
            schedule = .group(.init(groupName: name))
        case .lector(let employee):
            schedule = .lector(.init(lector: employee))
        }
        path = StackState()
    }

    mutating func resetPinned() {
        schedule = nil
        path = StackState()
    }

    mutating func reset() {
        schedule?.reset()
        path = StackState()
    }
}
