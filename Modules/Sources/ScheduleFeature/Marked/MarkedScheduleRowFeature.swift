import Foundation
import ComposableArchitecture
import ScheduleCore

// TODO: Sync state with Shared

@Reducer
public struct MarkedScheduleRowFeature {
    @ObservableState
    public struct State {
        let source: ScheduleSource
        
        public var isFavorite: Bool {
            switch source {
            case .group(let name):
                favoriteGroupNames.contains(name)
            case .lector(let employee):
                favoriteLecturerIDs.contains(employee.id)
            }
        }

        public var isPinned: Bool {
            pinnedSchedule.source == source
        }

        @Presents var alert: AlertState<PinPremiumAlertAction>?

        @SharedReader(.pinnedSchedule) var pinnedSchedule
        @SharedReader(.favoriteGroupNames) var favoriteGroupNames
        @SharedReader(.favoriteLecturerIDs) var favoriteLecturerIDs
        @SharedReader(.isPremiumUser) var isPremiumUser

        public init(source: ScheduleSource) {
            self.source = source
        }
    }

    public enum Action {
        public enum DelegateAction {
            case showPremiumClub
        }

        case toggleFavoriteTapped
        case togglePinnedTapped
        case removeButtonTapped

        case delegate(DelegateAction)
        case alert(PresentationAction<PinPremiumAlertAction>)
    }

    @Dependency(\.scheduleMarkingService) var scheduleMarkingService

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .toggleFavoriteTapped:
                return .run { [isFavorite = state.isFavorite, source = state.source] _ in
                    await isFavorite
                        ? scheduleMarkingService.unfavorite(source)
                        : scheduleMarkingService.favorite(source)
                }

            case .togglePinnedTapped:
                if !state.isPinned, !state.isPremiumUser {
                    state.alert = .premiumLocked
                    return .none
                }

                return .run { [isPinned = state.isPinned, source = state.source] _ in
                    await isPinned
                        ? scheduleMarkingService.unpin(source)
                        : scheduleMarkingService.pin(source)
                }

            case .removeButtonTapped:
                return .run { [source = state.source] _ in
                    await scheduleMarkingService.unfavorite(source)
                    await scheduleMarkingService.unpin(source)
                }

            case .alert(.presented(.learnAboutPremiumClubButtonTapped)):
                return .send(.delegate(.showPremiumClub))

            case .alert, .delegate:
                return .none
            }
        }
        .ifLet(\.alert, action: \.alert)
    }
}
