import Foundation
import ComposableArchitecture
import ScheduleCore

@Reducer
public struct MarkedScheduleRowFeature {
    @ObservableState
    public struct State: Equatable {
        let source: ScheduleSource
        var isFavorite: Bool
        var isPinned: Bool
        @Presents var alert: AlertState<PinPremiumAlertAction>?

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
        case toggleFavoriteTapped
        case togglePinnedTapped

        case _setIsFavorite(Bool)
        case _setIsPinned(Bool)

        case delegate(DelegateAction)
        case alert(PresentationAction<PinPremiumAlertAction>)
    }

    @Dependency(\.scheduleMarkingService) var scheduleMarkingService
    @Dependency(\.premiumService) var premiumService

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                return .merge(
                    observeIsPinned(source: state.source),
                    observeIsFavorite(source: state.source)
                )

            case .toggleFavoriteTapped:
                state.isFavorite.toggle()
                return .run { [isFavorite = state.isFavorite, source = state.source] _ in
                    await isFavorite
                        ? scheduleMarkingService.favorite(source)
                        : scheduleMarkingService.unfavorite(source)
                }

            case .togglePinnedTapped:
                if !state.isPinned, !premiumService.isCurrentlyPremium {
                    state.alert = .premiumLocked
                    return .none
                }

                state.isPinned.toggle()
                return .run { [isPinned = state.isPinned, source = state.source] _ in
                    await isPinned
                        ? scheduleMarkingService.pin(source)
                        : scheduleMarkingService.unpin(source)
                }

            case ._setIsFavorite(let value):
                state.isFavorite = value
                return .none

            case ._setIsPinned(let value):
                state.isPinned = value
                return .none

            case .alert(.presented(.learnAboutPremiumClubButtonTapped)):
                return .send(.delegate(.showPremiumClub))

            case .alert, .delegate:
                return .none
            }
        }
        .ifLet(\.alert, action: \.alert)
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
