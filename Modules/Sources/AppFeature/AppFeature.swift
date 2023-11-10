import Foundation
import GroupsFeature
import LecturersFeature
import SettingsFeature
import Deeplinking
import Favorites
import ScheduleCore
import PremiumClubFeature
import ComposableArchitecture
import EntityScheduleFeature
import ScheduleFeature

public struct AppFeature: Reducer {
    public struct State: Equatable {
        enum Destination: Equatable {
            case settings(SettingsFeature.State)
            case premiumClub(PremiumClubFeature.State)
        }

        @PresentationState var destination: Destination?

        var selection: CurrentSelection = .groups

        var premiumClub = PremiumClubFeature.State(isModal: true)
        var pinnedTab: PinnedTabFeature.State
        var groups = GroupsFeature.State()
        var lecturers = LecturersFeature.State()
        var settings = SettingsFeature.State()

        public init() {
            self.pinnedTab = .init(isPremiumLocked: !premiumClub.hasPremium)
            @Dependency(\.favorites) var favorites
            @Dependency(\.pinnedScheduleService) var pinnedScheduleService
            self.handleInitialSelection(favorites: favorites, pinnedScheduleService: pinnedScheduleService)
        }
    }

    public enum Action {
        public enum DestinationAction {
            case settings(SettingsFeature.Action)
            case premiumClub(PremiumClubFeature.Action)
        }

        case destination(PresentationAction<DestinationAction>)

        case task
        case closePremiumClubButtonTapped

        case handleDeeplink(URL)
        case setSelection(CurrentSelection)
        case setPinnedSchedule(ScheduleSource?)
        case showSettingsButtonTapped

        case premiumClub(PremiumClubFeature.Action)
        case pinnedTab(PinnedTabFeature.Action)
        case groups(GroupsFeature.Action)
        case lecturers(LecturersFeature.Action)
        case settings(SettingsFeature.Action)
    }

    @Dependency(\.favorites) var favorites
    @Dependency(\.productsService) var productsService
    @Dependency(\.pinnedScheduleService) var pinnedScheduleService

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                return .merge(
                    .send(.premiumClub(.task)),
                    .run { send in
                        for await pinnedSchedule in pinnedScheduleService.schedule().values {
                            // Give time for schedule feature to handle unpin before removing tab view
                            await Task.yield()
                            await send(.setPinnedSchedule(pinnedSchedule))
                        }
                    }
                )

            case .closePremiumClubButtonTapped:
                state.destination = nil
                return .none

            case let .setSelection(value):
                state.updateSelection(value)
                return .none

            case .setPinnedSchedule(nil):
                state.pinnedTab.resetPinned()
                return .none

            case let .setPinnedSchedule(pinned?):
                state.pinnedTab.show(pinned: pinned)
                return .none

            case .showSettingsButtonTapped:
                state.destination = .settings(state.settings)
                return .none

            case let .handleDeeplink(url):
                do {
                    let deeplink = try deeplinkRouter.match(url: url)
                    handleDeeplink(state: &state, deeplink: deeplink)
                } catch {
                    assertionFailure("Failed to parse deeplink. \(error.localizedDescription)")
                }
                return .none

            case let .premiumClub(._setIsPremium(value)):
                state.pinnedTab.isPremiumLocked = !value
                return .none

            case .pinnedTab(.delegate(let action)):
                switch action {
                case .showPremiumClubPinned:
                    state.showPremiumClub(source: .pin)
                    return .none
                }

            case .groups(.delegate(let action)):
                switch action {
                case .showPremiumClubPinned:
                    state.showPremiumClub(source: .pin)
                    return .none
                }

            case .lecturers(.delegate(let action)):
                switch action {
                case .showPremiumClubPinned:
                    state.showPremiumClub(source: .pin)
                    return .none
                }

            case .settings(.delegate(let action)):
                switch action {
                case let .showPremiumClub(source):
                    state.showPremiumClub(source: source)
                    return .none
                }

            case .groups, .lecturers, .settings, .pinnedTab, .premiumClub, .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: /Action.destination) {
            Scope(state: /State.Destination.settings, action: /Action.DestinationAction.settings) {
                SettingsFeature()
            }

            Scope(state: /State.Destination.premiumClub, action: /Action.DestinationAction.premiumClub) {
                PremiumClubFeature()
            }
        }

        Scope(state: \.premiumClub, action: /Action.premiumClub) {
            PremiumClubFeature()
        }

        Scope(state: \.pinnedTab, action: /Action.pinnedTab) {
            PinnedTabFeature()
        }

        Scope(state: \.groups, action: /Action.groups) {
            GroupsFeature()
        }

        Scope(state: \.lecturers, action: /Action.lecturers) {
            LecturersFeature()
        }

        Scope(state: \.settings, action: /Action.settings) {
            SettingsFeature()
        }
    }
}

// MARK: - Deeplink


private extension AppFeature {

    func handleDeeplink(state: inout State, deeplink: Deeplink) {
        switch deeplink {
        case let .pinned(displayType):
            handlePinnedDeeplink(state: &state, deeplinkDisplayType: displayType)
        case .groups:
            state.selection = .groups
            state.groups.reset()
        case let .group(name, displayType):
            handleDeeplink(state: &state, groupName: name, deeplinkDisplayType: displayType)
        case .lecturers:
            state.selection = .lecturers
            state.lecturers.reset()
        case let .lector(id, displayType):
            handleDeeplink(state: &state, lectorId: id, deeplinkDisplayType: displayType)
        case .settings:
            state.selection = .settings
            state.settings.reset()
        case let .premiumClub(source):
            state.selection = .settings
            state.settings.openPremiumClub(source: .init(deeplinkSource: source))
        }
    }

    func handleDeeplink(
        state: inout State,
        groupName: String,
        deeplinkDisplayType: ScheduleDeeplinkDisplayType?
    ) {
        switch pinnedScheduleService.currentSchedule() {
        case .group(groupName):
            handlePinnedDeeplink(state: &state, deeplinkDisplayType: deeplinkDisplayType)
        case .group, .lector, nil:
            state.selection = .groups
            state.groups.openGroup(named: groupName, displayType: displayType(for: deeplinkDisplayType))
        }
    }

    func handleDeeplink(
        state: inout State,
        lectorId: Int,
        deeplinkDisplayType: ScheduleDeeplinkDisplayType?
    ) {
        switch pinnedScheduleService.currentSchedule() {
        case .lector(let lector) where lector.id == lectorId:
            handlePinnedDeeplink(state: &state, deeplinkDisplayType: deeplinkDisplayType)
        case .lector, .group, nil:
            state.selection = .lecturers
            state.lecturers.openLector(id: lectorId, displayType: displayType(for: deeplinkDisplayType))
        }
    }

    func handlePinnedDeeplink(
        state: inout State,
        deeplinkDisplayType: ScheduleDeeplinkDisplayType?
    ) {
        state.selection = .pinned
        state.pinnedTab.switchDisplayType(displayType(for: deeplinkDisplayType))
    }

    func displayType(for deeplinkDisplayType: ScheduleDeeplinkDisplayType?) -> ScheduleDisplayType {
        switch deeplinkDisplayType {
        case .continuous, nil: .continuous
        case .compact: .compact
        case .exams: .exams
        }
    }
}

// MARK: - Selection

private extension AppFeature.State {
    mutating func handleInitialSelection(
        favorites: FavoritesService,
        pinnedScheduleService: PinnedScheduleService
    ) {
        if let pinnedSchedule = pinnedScheduleService.currentSchedule() {
            selection = .pinned
            pinnedTab.show(pinned: pinnedSchedule)
            return
        }

        if let groupName = favorites.currentGroupNames.first {
            selection = .groups
            groups.openGroup(named: groupName)
            return
        }

        if let lectorId = favorites.currentLectorIds.first {
            selection = .lecturers
            lecturers.openLector(id: lectorId)
            return
        }
    }

    mutating func updateSelection(_ newValue: CurrentSelection) {
        guard newValue == selection else {
            selection = newValue
            return
        }

        // Handle tap on already selected tab
        switch newValue {
        case .pinned:
            pinnedTab.reset()
        case .groups:
            groups.reset()
        case .lecturers:
            lecturers.reset()
        case .settings:
            settings.reset()
        }
    }
}

// MARK: - Premium Club

private extension AppFeature.State {
    mutating func showPremiumClub(source: PremiumClubFeature.Source?) {
        premiumClub.source = source
        destination = .premiumClub(premiumClub)
    }
}

// MARK: - PremiumClubFeature.Source

private extension PremiumClubFeature.Source {
    init?(deeplinkSource: PremiumClubDeeplinkSource?) {
        guard let deeplinkSource else { return nil }
        switch deeplinkSource {
        case .appIcon: self = .appIcon
        case .pin: self = .pin
        }
    }
}
