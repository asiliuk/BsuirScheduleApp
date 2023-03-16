import PremiumClubFeature
import EntityScheduleFeature
import ScheduleCore
import ComposableArchitecture
import ComposableArchitectureUtils

public struct PinnedTabFeature: Reducer {
    public struct State: Equatable {
        var isPremiumLocked: Bool
        var schedule: PinnedScheduleFeature.State?
    }

    public enum Action: Equatable, FeatureAction {
        public enum ViewAction: Equatable {
            case learnAboutPremiumClubTapped
        }

        public enum ReducerAction: Equatable {
            case schedule(PinnedScheduleFeature.Action)
        }

        public enum DelegateAction: Equatable {
            case showPremiumClubPinned
            case showPremiumClubFakeAdsBanner
        }

        case view(ViewAction)
        case reducer(ReducerAction)
        case delegate(DelegateAction)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(.learnAboutPremiumClubTapped):
                return .send(.delegate(.showPremiumClubPinned))

            case .reducer(.schedule(.delegate(let action))):
                switch action {
                case .showPremiumClubPinned:
                    return .send(.delegate(.showPremiumClubPinned))
                case .showPremiumClubFakeAdsBanner:
                    return .send(.delegate(.showPremiumClubFakeAdsBanner))
                }

            case .reducer, .delegate:
                return .none
            }
        }
        .ifLet(\.schedule, reducerAction: /Action.ReducerAction.schedule) {
            PinnedScheduleFeature()
        }
    }
}

// MARK: - Selection

extension PinnedTabFeature.State {
    mutating func show(pinned pinnedSchedule: ScheduleSource) {
        schedule = .init(pinned: pinnedSchedule)
    }

    mutating func resetPinned() {
        schedule = nil
    }

    mutating func reset() {
        schedule?.reset()
    }
}
