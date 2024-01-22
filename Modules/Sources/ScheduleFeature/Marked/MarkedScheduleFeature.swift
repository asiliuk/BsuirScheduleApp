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
        @PresentationState public var alert: AlertState<Action.AlertAction>?
        public var isFavorite: Bool = false
        public var isPinned: Bool = false
        var isPremiumLocked: Bool
        let source: ScheduleSource

        public init(source: ScheduleSource) {
            self.source = source
            @Dependency(\.premiumService) var premiumService
            self.isPremiumLocked = !premiumService.isCurrentlyPremium
            @Dependency(\.favorites) var favorites
            self.isFavorite = switch source {
            case let .group(name): favorites.currentGroupNames.contains(name)
            case let .lector(lector): favorites.currentLectorIds.contains(lector.id)
            }
            @Dependency(\.pinnedScheduleService) var pinnedScheduleService
            self.isPinned = pinnedScheduleService.currentSchedule() == source
        }
    }

    public enum Action: Equatable {
        public enum AlertAction: Equatable {
            case learnAboutPremiumClubButtonTapped
        }

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
        case _setIsPremiumLocked(Bool)

        case delegate(DelegateAction)
        case alert(PresentationAction<AlertAction>)
    }

    @Dependency(\.favorites) var favorites
    @Dependency(\.pinnedScheduleService) var pinnedScheduleService
    @Dependency(\.reviewRequestService) var reviewRequestService
    @Dependency(\.premiumService) var premiumService

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .task:
                return .merge(
                    observeIsPinned(source: state.source),
                    observeIsFavorite(source: state.source),
                    observeIsPremium()
                )

            case .favoriteButtonTapped:
                return favorite(source: state.source)

            case .unfavoriteButtonTapped:
                return unfavorite(source: state.source)

            case .pinButtonTapped:
                if state.isPremiumLocked {
                    state.alert = .premiumLocked
                    return .none
                } else {
                    return pin(source: state.source)
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

            case let ._setIsPremiumLocked(value):
                state.isPremiumLocked = value
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
            // Remove schedule from pinned if needed
            if pinnedScheduleService.currentSchedule() == source {
                pinnedScheduleService.setCurrentSchedule(nil)
            }
            // Add schedule to favorites
            favorites.addToFavorites(source: source)
            // Log meaningful event
            await reviewRequestService.madeMeaningfulEvent(.addToFavorites)
        }
    }

    private func unfavorite(source: ScheduleSource) -> Effect<Action> {
        return .run { _ in
            favorites.removeFromFavorites(source: source)
        }
    }

    private func pin(source: ScheduleSource) -> Effect<Action> {
        return .run { _ in
            // Move previously pinned schedule to favorites
            if let pinned = pinnedScheduleService.currentSchedule() {
                favorites.addToFavorites(source: pinned)
            }
            // Remove newly pinned schedule from favorites
            favorites.removeFromFavorites(source: source)
            // Make new schedule as pinned
            pinnedScheduleService.setCurrentSchedule(source)
            // Log meaningful event
            await reviewRequestService.madeMeaningfulEvent(.pin)
        }
    }

    private func unpin(source: ScheduleSource) -> Effect<Action> {
        return .run { _ in
            if pinnedScheduleService.currentSchedule() == source {
                pinnedScheduleService.setCurrentSchedule(nil)
            }
        }
    }

    private func observeIsPinned(source: ScheduleSource) -> Effect<Action> {
        .run { send in
            for await value in pinnedScheduleService.schedule().map({ $0 == source }).removeDuplicates().values {
                await send(._setIsPinned(value))
            }
        }
    }

    private func observeIsFavorite(source: ScheduleSource) -> Effect<Action> {
        switch source {
        case let .group(name):
            return observeIsFavorite(source: favorites.groupNames.map { $0.contains(name) })
        case let .lector(lector):
            return observeIsFavorite(source: favorites.lecturerIds.map { $0.contains(lector.id) })
        }
    }

    private func observeIsFavorite(source: some Publisher<Bool, Never>) -> Effect<Action> {
        return .run { send in
            for await value in source.removeDuplicates().values {
                await send(._setIsFavorite(value))
            }
        }
    }

    private func observeIsPremium() -> Effect<Action> {
        return .run { send in
            for await value in premiumService.isPremium.removeDuplicates().values {
                await send(._setIsPremiumLocked(!value))
            }
        }
    }
}

// MARK: - MeaningfulEvent

private extension MeaningfulEvent {
    static let addToFavorites = Self(score: 5)
    static let pin = Self(score: 5)
}

// MARK: - Alert

private extension AlertState where Action == MarkedScheduleFeature.Action.AlertAction {
    static let premiumLocked = AlertState(
        title: TextState("alert.premiumClub.pinnedSchedule.title"),
        message: TextState("alert.premiumClub.pinnedSchedule.message"),
        buttons: [
            .default(
                TextState("alert.premiumClub.pinnedSchedule.button"),
                action: .send(.learnAboutPremiumClubButtonTapped)
            ),
            .cancel(TextState("alert.premiumClub.pinnedSchedule.cancel"))
        ]
    )
}
