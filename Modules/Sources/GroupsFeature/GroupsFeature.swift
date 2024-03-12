import Foundation
import ComposableArchitecture
import EntityScheduleFeature
import LoadableFeature
import ScheduleFeature

@Reducer
public struct GroupsFeature {
    @ObservableState
    public struct State {
        /// Designed to defer group presentation to the moment when component was presented
        enum GroupPresentationMode: Equatable {
            /// initial state, attempts to present group in this mode would end up deferred
            case initial
            /// deferred, means that there were attempt to present group before component appeared
            case deferred(String, displayType: ScheduleDisplayType)
            /// immediate, meaning component was presented and all attempts to present group should not be deferred
            case immediate
        }

        // MARK: Navigation
        var path = StackState<EntityScheduleFeatureV2.State>()
        var groupPresentationMode: GroupPresentationMode = .initial
        
        // MARK: Placeholder
        var hasPinnedPlaceholder: Bool  = false
        var favoritesPlaceholderCount: Int = 0

        // MARK: Groups
        var groups: LoadingState<LoadedGroupsFeature.State> = .initial

        // MARK: Force Add
        @Presents var forceAddAlert: ForceAddAlert.State?

        public init() {}
    }

    public enum Action {
        public enum Delegate: Equatable {
            case showPremiumClubPinned
        }

        case task
        case onAppear
        case forceAddGroupButtonTapped
        case forceAddAlert(PresentationAction<ForceAddAlert.Action>)

        case groups(LoadingActionOf<LoadedGroupsFeature>)
        case path(StackAction<EntityScheduleFeatureV2.State, EntityScheduleFeatureV2.Action>)
        case delegate(Delegate)
    }

    @Dependency(\.apiClient) var apiClient
    @Dependency(\.favorites.currentGroupNames) var favoriteGroupNames
    @Dependency(\.pinnedScheduleService.currentSchedule) var pinnedSchedule

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.hasPinnedPlaceholder = pinnedSchedule()?.groupName != nil
                state.favoritesPlaceholderCount = favoriteGroupNames.count
                return .none

            case .task:
                // Very important to do in task if done in `onAppear`
                // schedule screen is not properly loaded and got stuck in placeholder state
                state.presentDeferredGroupIfNeeded()
                return .none

            case .forceAddGroupButtonTapped:
                state.forceAddAlert = .init()
                return .none

            case .groups(.loaded(.delegate(let action))):
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

            case .groups, .path, .forceAddAlert, .delegate:
                return .none
            }
        }
        .load(state: \.groups, action: \.groups) { _, isRefresh in
            let groups = try await apiClient.groups(isRefresh)
            return LoadedGroupsFeature.State(
                groups: groups,
                favoritesNames: favoriteGroupNames,
                pinnedName: pinnedSchedule()?.groupName
            )
        } loaded: {
            LoadedGroupsFeature()
        }
        .forEach(\.path, action: \.path)
        .ifLet(\.$forceAddAlert, action: \.forceAddAlert) {
            ForceAddAlert()
        }
    }
}

// MARK: - Force Add

@Reducer
public struct ForceAddAlert {
    @ObservableState
    public struct State: Equatable {
        var groupName: String = ""
    }

    public enum Action: Equatable, BindableAction {
        case addButtonTapped
        case cancelButtonTapped
        case binding(BindingAction<State>)
    }

    @Dependency(\.favorites) var favorites

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .addButtonTapped:
                if !state.groupName.isEmpty {
                    favorites.addToFavorites(source: .group(name: state.groupName))
                }
                return .none
            case .cancelButtonTapped:
                return .none
            case .binding:
                return .none
            }
        }
    }
}
