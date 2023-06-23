import PremiumClubFeature
import EntityScheduleFeature
import ScheduleCore
import ComposableArchitecture

public struct PinnedTabFeature: ReducerProtocol {
    public struct State: Equatable {
        var isPremiumLocked: Bool
        var schedule: PinnedScheduleFeature.State?
    }

    public enum Action: Equatable {
        public enum DelegateAction: Equatable {
            case showPremiumClubPinned
            case showPremiumClubFakeAdsBanner
        }

        case schedule(PinnedScheduleFeature.Action)
        case learnAboutPremiumClubTapped
        case delegate(DelegateAction)
    }

    public var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .learnAboutPremiumClubTapped:
                return .send(.delegate(.showPremiumClubPinned))

            case .schedule(.delegate(let action)):
                switch action {
                case .showPremiumClubPinned:
                    return .send(.delegate(.showPremiumClubPinned))
                case .showPremiumClubFakeAdsBanner:
                    return .send(.delegate(.showPremiumClubFakeAdsBanner))
                }

            case .schedule, .delegate:
                return .none
            }
        }
        .ifLet(\.schedule, action: /Action.schedule) {
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
