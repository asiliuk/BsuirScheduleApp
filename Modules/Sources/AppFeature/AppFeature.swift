import Foundation
import GroupsFeature
import LecturersFeature
import AboutFeature
import Deeplinking
import Favorites
import ComposableArchitecture
import ComposableArchitectureUtils
import EntityScheduleFeature

public struct AppFeature: ReducerProtocol {
    public struct State: Equatable {
        var selection: CurrentSelection = .groups
        var overlay: CurrentOverlay?

        struct Pinned: Equatable {
            var title: String
            var schedule: PinnedScheduleFeature.State
        }

        var pinned: Pinned?
        var groups = GroupsFeature.State()
        var lecturers = LecturersFeature.State()
        var about = AboutFeature.State()

        public init() {
            @Dependency(\.favorites) var favorites
            self.handleInitialSelection(favorites: favorites)
        }
    }

    public enum Action {
        case task

        case handleDeeplink(URL)
        case setSelection(CurrentSelection)
        case setOverlay(CurrentOverlay?)
        case setPinnedSchedule(PinnedSchedule?)
        case showAboutButtonTapped

        case pinned(PinnedScheduleFeature.Action)
        case groups(GroupsFeature.Action)
        case lecturers(LecturersFeature.Action)
        case about(AboutFeature.Action)
    }

    @Dependency(\.favorites) var favorites

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .task:
                return .run { send in
                    for await pinnedSchedule in favorites.pinnedSchedule.values {
                        await send(.setPinnedSchedule(pinnedSchedule))
                    }
                }

            case let .setSelection(value):
                updateSelection(state: &state, value)
                state.selection = value
                return .none

            case let .setOverlay(value):
                state.overlay = value
                return .none

            case .setPinnedSchedule(nil):
                state.pinned = nil
                return .none

            case let .setPinnedSchedule(pinned?):
                state.pinned = .init(pinned)
                return .none

            case .showAboutButtonTapped:
                state.overlay = .about
                return .none

            case let .handleDeeplink(url):
                do {
                    let deeplink = try deeplinkRouter.match(url: url)
                    handleDeepling(state: &state, deeplink: deeplink)
                } catch {
                    assertionFailure("Failed to parse deeplink. \(error.localizedDescription)")
                }
                return .none

            case .groups, .lecturers, .about, .pinned:
                return .none
            }
        }
        .ifLet(\.pinned, action: /Action.pinned) {
            Scope(state: \.schedule, action: .self) {
                PinnedScheduleFeature()
            }
        }

        Scope(state: \.groups, action: /Action.groups) {
            GroupsFeature()
        }

        Scope(state: \.lecturers, action: /Action.lecturers) {
            LecturersFeature()
        }

        Scope(state: \.about, action: /Action.about) {
            AboutFeature()
        }
    }

    private func handleDeepling(state: inout State, deeplink: Deeplink) {
        switch deeplink {
        case .groups:
            state.selection = .groups
            state.groups.reset()
        case let .group(name):
            state.selection = .groups
            state.groups.openGroup(named: name)
        case .lecturers:
            state.selection = .lecturers
            state.lecturers.reset()
        case let .lector(id):
            state.selection = .lecturers
            state.lecturers.openLector(id: id)
        case .about:
            state.selection = .about
            state.about.reset()
        }
    }

    private func updateSelection(state: inout State, _ newValue: CurrentSelection) {
        guard newValue == state.selection else {
            state.selection = newValue
            return
        }

        // Handle tap on already selected tab
        switch newValue {
        case .pinned:
            state.pinned?.schedule.reset()
        case .groups:
            state.groups.reset()
        case .lecturers:
            state.lecturers.reset()
        case .about:
            state.about.reset()
        }
    }
}

private extension AppFeature.State {
    mutating func handleInitialSelection(favorites: FavoritesContainer) {
        if let pinnedSchedule = favorites.currentPinnedSchedule {
            selection = .pinned(pinnedSchedule.tabTitle)
            pinned = .init(pinnedSchedule)
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
}

private extension PinnedSchedule {
    var tabTitle: String {
        switch self {
        case let .group(name):
            return name
        case let .lector(lector):
            return lector.compactFio
        }
    }
}

private extension AppFeature.State.Pinned {
    init(_ pinned: PinnedSchedule) {
        self.init(
            title: pinned.tabTitle,
            schedule: .init(pinned: pinned)
        )
    }
}
