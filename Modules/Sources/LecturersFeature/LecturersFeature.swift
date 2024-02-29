import Foundation
import ComposableArchitecture
import EntityScheduleFeature
import LoadableFeature
import ScheduleFeature

@Reducer
public struct LecturersFeature {
    @ObservableState
    public struct State {
        /// Designed to defer lector schedule presentation to the moment when lectors list was loaded
        enum LectorPresentationMode: Equatable {
            /// initial state, attempts to present lector in this mode would end up deferred
            case initial
            /// deferred, means that there were attempt to present lector before data was loaded
            case deferred(id: Int, displayType: ScheduleDisplayType)
            /// immediate, meaning component was presented and all attempts to present lector should not be deferred
            case immediate
        }

        // MARK: Navigation
        var path = StackState<EntityScheduleFeatureV2.State>()
        var lectorPresentationMode: LectorPresentationMode = .initial

        // MARK: Placeholder
        var hasPinnedPlaceholder: Bool  = false
        var favoritesPlaceholderCount: Int = 0

        // MARK: Lecturers
        var lecturers: LoadingState<LoadedLecturersFeature.State> = .initial

        public init() {}
    }

    public enum Action {
        public enum Delegate {
            case showPremiumClubPinned
        }

        case onAppear

        case path(StackAction<EntityScheduleFeatureV2.State, EntityScheduleFeatureV2.Action>)
        case lecturers(LoadingActionOf<LoadedLecturersFeature>)

        case delegate(Delegate)
    }

    @Dependency(\.apiClient) var apiClient
    @Dependency(\.favorites.currentLectorIds) var favoriteLectorIds
    @Dependency(\.pinnedScheduleService.currentSchedule) var pinnedSchedule

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.hasPinnedPlaceholder = pinnedSchedule()?.lector != nil
                state.favoritesPlaceholderCount = favoriteLectorIds.count
                return .none

            case .lecturers(.fetchFinished):
                state.presentDeferredLectorIfNeeded()
                return .none

            case .lecturers(.loaded(.lecturerRows(.element(let lectorId, action: .rowTapped)))):
                state.presentLector(state.lecturers.loaded?.lector(withId: lectorId))
                return .none

            case .lecturers(.loaded(.lecturerRows(.element(_, action: .mark(.delegate(let action)))))):
                switch action {
                case .showPremiumClub:
                    return .send(.delegate(.showPremiumClubPinned))
                }

            case .path(.element(_, .group(.schedule(.delegate(let action))))),
                 .path(.element(_, .lector(.schedule(.delegate(let action))))):
                switch action {
                case .showPremiumClubPinned:
                    return .send(.delegate(.showPremiumClubPinned))
                case .showLectorSchedule(let employee):
                    state.path.append(.lector(.init(lector: employee)))
                    return .none
                case .showGroupSchedule(let groupName):
                    state.path.append(.group(.init(groupName: groupName)))
                    return .none
                }

            case .delegate, .path, .lecturers:
                return .none
            }
        }
        .load(state: \.lecturers, action: \.lecturers) { _, isRefresh in
            let lecturers = try await apiClient.lecturers(isRefresh)
            return LoadedLecturersFeature.State(
                lecturers: lecturers,
                favoritesIds: favoriteLectorIds,
                pinnedId: pinnedSchedule()?.lector?.id
            )
        } loaded: {
            LoadedLecturersFeature()
        }
        .forEach(\.path, action: \.path)
    }
}
