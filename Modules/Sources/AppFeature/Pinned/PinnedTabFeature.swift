import PremiumClubFeature
import EntityScheduleFeature
import ScheduleCore
import ComposableArchitecture

public struct PinnedTabFeature: Reducer {
    public struct State: Equatable {
        var showModalPremiumClub: Bool = false
        var schedule: PinnedScheduleFeature.State?
        var premiumClub = PremiumClubFeature.State(source: .pin)
    }

    public enum Action: Equatable {
        case learnAboutPremiumClubTapped
        case setShowModalPremiumClub(Bool)
        case schedule(PinnedScheduleFeature.Action)
        case premiumClub(PremiumClubFeature.Action)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .learnAboutPremiumClubTapped:
                state.showModalPremiumClub = true
                return .none

            case let .setShowModalPremiumClub(value):
                state.showModalPremiumClub = value
                return .none

            case .schedule, .premiumClub:
                return .none
            }
        }
        .ifLet(\.schedule, action: /Action.schedule) {
            PinnedScheduleFeature()
        }

        Scope(state: \.premiumClub, action: /Action.premiumClub) {
            PremiumClubFeature()
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
