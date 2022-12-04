import Foundation
import GroupsFeature
import LecturersFeature
import AboutFeature
import Deeplinking
import Favorites
import ComposableArchitecture
import ComposableArchitectureUtils

public struct AppFeature: ReducerProtocol {
    public struct State: Equatable {
        var selection: CurrentSelection = .groups
        var overlay: CurrentOverlay?

        var groups = GroupsFeature.State()
        var lecturers = LecturersFeature.State()
        var about = AboutFeature.State()

        public init() {}
    }

    public enum Action {
        case onAppear

        case handleDeeplink(URL)
        case setSelection(CurrentSelection)
        case setOverlay(CurrentOverlay?)
        case showAboutButtonTapped

        case groups(GroupsFeature.Action)
        case lecturers(LecturersFeature.Action)
        case about(AboutFeature.Action)
    }

    @Dependency(\.favorites) var favorites

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                handleInitialSelection(state: &state)
                return .none

            case let .setSelection(value):
                updateSelection(state: &state, value)
                state.selection = value
                return .none

            case let .setOverlay(value):
                state.overlay = value
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

            case .groups, .lecturers, .about:
                return .none
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

    private func handleInitialSelection(state: inout State) {
        if let groupName = favorites.currentGroupNames.first {
            state.selection = .groups
            state.groups.openGroup(named: groupName)
            return
        }

        if let lector = favorites.currentLecturers.first {
            state.selection = .lecturers
            state.lecturers.openLector(lector)
            return
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
        case .groups:
            state.groups.reset()
        case .lecturers:
            state.lecturers.reset()
        case .about:
            state.about.reset()
        }
    }
}
