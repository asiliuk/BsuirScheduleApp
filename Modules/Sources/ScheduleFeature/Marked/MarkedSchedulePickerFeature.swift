import Foundation
import ComposableArchitecture
import ScheduleCore
import BsuirCore

@Reducer
public struct MarkedSchedulePickerFeature {
    @ObservableState
    public struct State: Equatable {
        enum Selection: Identifiable, Hashable, CaseIterable {
            var id: Self { self }
            case pinned
            case favorite
            case nothing

            init(isFavorite: Bool, isPinned: Bool) {
                if isPinned {
                    self = .pinned
                } else if isFavorite {
                    self = .favorite
                } else {
                    self = .nothing
                }
            }
        }

        let source: ScheduleSource
        var selection: Selection
        @Presents var alert: AlertState<PinPremiumAlertAction>?
        @SharedReader(.isPremiumUser) var isPremiumUser

        init(source: ScheduleSource) {
            self.source = source
            @Dependency(\.scheduleMarkingService) var scheduleMarkingService
            selection = Selection(
                isFavorite: scheduleMarkingService.isCurrentlyFavorite(source),
                isPinned: scheduleMarkingService.isCurrentlyPinned(source)
            )
        }
    }

    public enum Action: Equatable, BindableAction {
        public enum DelegateAction: Equatable {
            case showPremiumClub
        }

        case task

        case _setIsFavorite(Bool)
        case _setIsPinned(Bool)

        case delegate(DelegateAction)
        case binding(BindingAction<State>)
        case alert(PresentationAction<PinPremiumAlertAction>)
    }

    @Dependency(\.scheduleMarkingService) var scheduleMarkingService

    public var body: some ReducerOf<Self> {
        BindingReducer()
            .onChange(of: \.selection) { _, selection in
                Reduce { state, action in
                    updateSelection(state: &state, selection: selection)
                }
            }

        Reduce { state, action in
            switch action {
            case .task:
                return .merge(
                    observeIsPinned(source: state.source),
                    observeIsFavorite(source: state.source)
                )

            case ._setIsFavorite(let value):
                state.selection = State.Selection(
                    isFavorite: value,
                    isPinned: scheduleMarkingService.isCurrentlyPinned(state.source)
                )
                return .none

            case ._setIsPinned(let value):
                state.selection = State.Selection(
                    isFavorite: scheduleMarkingService.isCurrentlyFavorite(state.source),
                    isPinned: value
                )
                return .none

            case .alert(.presented(.learnAboutPremiumClubButtonTapped)):
                return .send(.delegate(.showPremiumClub))

            case .binding, .alert, .delegate:
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

    private func updateSelection(state: inout State, selection: State.Selection) -> Effect<Action> {
        let source = state.source
        switch selection {
        case .favorite:
            return .run { _ in await scheduleMarkingService.favorite(source) }
        case .pinned:
            if state.isPremiumUser {
                return .run { _ in
                    await scheduleMarkingService.pin(source)
                }
            } else {
                state.alert = .premiumLocked
                return .none
            }
        case .nothing:
            return .run { _ in
                await scheduleMarkingService.unfavorite(source)
                await scheduleMarkingService.unpin(source)
            }
        }
    }
}
