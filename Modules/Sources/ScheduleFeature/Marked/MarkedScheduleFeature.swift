import Foundation
import Combine
import BsuirCore
import ScheduleCore
import Favorites
import PremiumClubFeature
import ComposableArchitecture

@Reducer
public struct MarkedScheduleFeature {
    public struct State: Equatable {
        @PresentationState var alert: AlertState<PinPremiumAlertAction>?
        var isFavorite: Bool = false
        var isPinned: Bool = false
        let source: ScheduleSource

        public init(source: ScheduleSource) {
            self.source = source
            @Dependency(\.scheduleMarkingService) var scheduleMarkingService
            self.isFavorite = scheduleMarkingService.isCurrentlyFavorite(source)
            self.isPinned = scheduleMarkingService.isCurrentlyPinned(source)
        }
    }

    public enum Action: Equatable {
        public enum DelegateAction: Equatable {
            case showPremiumClub
        }

        case task
        case favoriteButtonTapped
        case unfavoriteButtonTapped
        case pinButtonTapped
        case unpinButtonTapped
        case unsaveButtonTapped

        case _setIsFavorite(Bool)
        case _setIsPinned(Bool)

        case delegate(DelegateAction)
        case alert(PresentationAction<PinPremiumAlertAction>)
    }

    @Dependency(\.premiumService) var premiumService
    @Dependency(\.scheduleMarkingService) var scheduleMarkingService

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .task:
                return .merge(
                    observeIsPinned(source: state.source),
                    observeIsFavorite(source: state.source)
                )

            case .favoriteButtonTapped:
                return favorite(source: state.source)

            case .unfavoriteButtonTapped:
                return unfavorite(source: state.source)

            case .pinButtonTapped:
                if premiumService.isCurrentlyPremium {
                    return pin(source: state.source)
                } else {
                    state.alert = .premiumLocked
                    return .none
                }

            case .unpinButtonTapped:
                return favorite(source: state.source)

            case .unsaveButtonTapped:
                return .merge(
                    unfavorite(source: state.source),
                    unpin(source: state.source)
                )

            case let ._setIsFavorite(value):
                state.isFavorite = value
                return .none

            case let ._setIsPinned(value):
                state.isPinned = value
                return .none

            case .alert(.presented(.learnAboutPremiumClubButtonTapped)):
                return .send(.delegate(.showPremiumClub))

            case .alert, .delegate:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }

    private func favorite(source: ScheduleSource) -> Effect<Action> {
        return .run { _ in
            await scheduleMarkingService.favorite(source)
        }
    }

    private func unfavorite(source: ScheduleSource) -> Effect<Action> {
        return .run { _ in
            await scheduleMarkingService.unfavorite(source)
        }
    }

    private func pin(source: ScheduleSource) -> Effect<Action> {
        return .run { _ in
            await scheduleMarkingService.pin(source)
        }
    }

    private func unpin(source: ScheduleSource) -> Effect<Action> {
        return .run { _ in
            await scheduleMarkingService.unpin(source)
        }
    }

    private func observeIsPinned(source: ScheduleSource) -> Effect<Action> {
        .run { send in
            for await value in scheduleMarkingService.isPinned(source).values {
                await send(._setIsPinned(value))
            }
        }
    }

    private func observeIsFavorite(source: ScheduleSource) -> Effect<Action> {
        .run { send in
            for await value in scheduleMarkingService.isFavorite(source).values {
                await send(._setIsFavorite(value))
            }
        }
    }
}
