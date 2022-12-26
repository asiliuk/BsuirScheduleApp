import Foundation
import Combine
import BsuirCore
import ScheduleCore
import Favorites
import ComposableArchitecture
import ComposableArchitectureUtils

public struct MarkedScheduleFeature: ReducerProtocol {
    public struct State: Equatable {
        public var isFavorite: Bool = false
        public var isPinned: Bool = false
        let source: ScheduleSource

        public init(source: ScheduleSource) {
            self.source = source
            @Dependency(\.favorites) var favorites
            self.update(favorites: favorites)
        }
    }

    public enum Action: Equatable, FeatureAction {
        public enum ViewAction: Equatable {
            case task
            case favoriteButtonTapped
            case unfavoriteButtonTapped
            case pinButtonTapped
            case unpinButtonTapped
            case unsaveButtonTapped
        }

        public enum ReducerAction: Equatable {
            case setIsFavorite(Bool)
            case setIsPinned(Bool)
        }

        public typealias DelegateAction = Never

        case view(ViewAction)
        case reducer(ReducerAction)
        case delegate(DelegateAction)
    }

    @Dependency(\.favorites) var favorites
    @Dependency(\.reviewRequestService) var reviewRequestService

    public init() {}

    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .view(.task):
            return .merge(
                observeIsPinned(source: state.source),
                observeIsFavorite(source: state.source)
            )

        case .view(.favoriteButtonTapped):
            return favorite(source: state.source)

        case .view(.unfavoriteButtonTapped):
            return unfavorite(source: state.source)

        case .view(.pinButtonTapped):
            return pin(source: state.source)

        case .view(.unpinButtonTapped):
            return favorite(source: state.source)

        case .view(.unsaveButtonTapped):
            return .merge(
                unfavorite(source: state.source),
                unpin(source: state.source)
            )

        case let .reducer(.setIsFavorite(value)):
            state.isFavorite = value
            return .none

        case let .reducer(.setIsPinned(value)):
            state.isPinned = value
            return .none
        }
    }

    private func favorite(source: ScheduleSource) -> EffectTask<Action> {
        return .merge(
            .fireAndForget {
                switch source {
                case .group(let name):
                    favorites.currentGroupNames.append(name)
                case .lector(let lector):
                    favorites.currentLectorIds.append(lector.id)
                }

                reviewRequestService.madeMeaningfulEvent(.addToFavorites)
            },
            // Unpin if currently pinned
            unpin(source: source)
        )
    }

    private func unfavorite(source: ScheduleSource) -> EffectTask<Action> {
        return .fireAndForget {
            switch source {
            case .group(let name):
                favorites.currentGroupNames.remove(name)
            case .lector(let lector):
                favorites.currentLectorIds.remove(lector.id)
            }
        }
    }

    private func pin(source: ScheduleSource) -> EffectTask<Action> {
        return .merge(
            // Move currently pinned schedule to favorites
            favorites.currentPinnedSchedule.map(favorite(source:)) ?? .none,
            unfavorite(source: source),
            .fireAndForget {
                favorites.currentPinnedSchedule = source
                reviewRequestService.madeMeaningfulEvent(.pin)
            }
        )
    }

    private func unpin(source: ScheduleSource) -> EffectTask<Action> {
        return .fireAndForget {
            if favorites.currentPinnedSchedule == source {
                favorites.currentPinnedSchedule = nil
            }
        }
    }

    private func observeIsPinned(source: ScheduleSource) -> EffectTask<Action> {
        .run { send in
            for await value in favorites.pinnedSchedule.map({ $0 == source }).removeDuplicates().values {
                await send(.reducer(.setIsPinned(value)))
            }
        }
    }

    private func observeIsFavorite(source: ScheduleSource) -> EffectTask<Action> {
        switch source {
        case let .group(name):
            return observeIsFavorite(source: favorites.groupNames.map { $0.contains(name) })
        case let .lector(lector):
            return observeIsFavorite(source: favorites.lecturerIds.map { $0.contains(lector.id) })
        }
    }

    private func observeIsFavorite(source: some Publisher<Bool, Never>) -> EffectTask<Action> {
        return .run { send in
            for await value in source.removeDuplicates().values {
                await send(.reducer(.setIsFavorite(value)))
            }
        }
    }
}

// MARK: - Update

private extension MarkedScheduleFeature.State {
    mutating func update(favorites: FavoritesContainer) {
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
