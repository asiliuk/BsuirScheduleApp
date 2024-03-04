import Foundation
import ComposableArchitecture
import ScheduleCore

@Reducer
public struct MarkedScheduleRowFeature {
    @ObservableState
    public struct State: Equatable {
        let source: ScheduleSource
        public var isFavorite: Bool
        public var isPinned: Bool
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

        case toggleFavoriteTapped
        case togglePinnedTapped
        case removeButtonTapped

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

            case .removeButtonTapped:
                state.isFavorite = false
                state.isPinned = false
                return .run { [source = state.source] _ in
                    await scheduleMarkingService.unfavorite(source)
                    await scheduleMarkingService.unpin(source)
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
}
