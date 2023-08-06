import Foundation
import Combine
import BsuirCore
import ScheduleCore
import Favorites
import PremiumClubFeature
import ComposableArchitecture

public struct MarkedScheduleFeature: Reducer {
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
            self.update(favorites: favorites)
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
        .ifLet(\.$alert, action: /Action.alert)
    }

    private func favorite(source: ScheduleSource) -> Effect<Action> {
        return .merge(
            .fireAndForget {
                switch source {
                case .group(let name):
                    favorites.currentGroupNames.append(name)
                case .lector(let lector):
                    favorites.currentLectorIds.append(lector.id)
                }

                await reviewRequestService.madeMeaningfulEvent(.addToFavorites)
            },
            // Unpin if currently pinned
            unpin(source: source)
        )
    }

    private func unfavorite(source: ScheduleSource) -> Effect<Action> {
        return .fireAndForget {
            switch source {
            case .group(let name):
                favorites.currentGroupNames.remove(name)
            case .lector(let lector):
                favorites.currentLectorIds.remove(lector.id)
            }
        }
    }

    private func pin(source: ScheduleSource) -> Effect<Action> {
        return .merge(
            // Move currently pinned schedule to favorites
            favorites.currentPinnedSchedule.map(favorite(source:)) ?? .none,
            unfavorite(source: source),
            .fireAndForget {
                favorites.currentPinnedSchedule = source
                await reviewRequestService.madeMeaningfulEvent(.pin)
            }
        )
    }

    private func unpin(source: ScheduleSource) -> Effect<Action> {
        return .fireAndForget {
            if favorites.currentPinnedSchedule == source {
                favorites.currentPinnedSchedule = nil
            }
        }
    }

    private func observeIsPinned(source: ScheduleSource) -> Effect<Action> {
        .run { send in
            for await value in favorites.pinnedSchedule.map({ $0 == source }).removeDuplicates().values {
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

// MARK: - Update

private extension MarkedScheduleFeature.State {
    mutating func update(favorites: FavoritesService) {
        isPinned = favorites.currentPinnedSchedule == source
        isFavorite = {
            switch source {
            case let .group(name):
                return favorites.currentGroupNames.contains(name)
            case let .lector(lector):
                return favorites.currentLectorIds.contains(lector.id)
            }
        }()
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
        title: TextState("Premium Club only"),
        message: TextState("Pinning of the schedule is available only for **Premium Club** members"),
        buttons: [
            .default(
                TextState("Join Premium Club..."),
                action: .send(.learnAboutPremiumClubButtonTapped)),
            .cancel(TextState("Cancel"))
        ]
    )
}
