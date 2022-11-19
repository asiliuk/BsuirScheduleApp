import Foundation
import GroupsFeature
import LecturersFeature
import AboutFeature
import ComposableArchitecture
import ComposableArchitectureUtils

struct AppFeature: ReducerProtocol {
    struct State: Equatable {
        var currentSelection: CurrentSelection
        var currentOverlay: CurrentOverlay?

        var groups = GroupsFeature.State()
        var lecturers = LecturersFeature.State()
        var about = AboutFeature.State()
    }

    enum Action {
        case handleDeeplink(URL)
        case setCurrentSelection(CurrentSelection)
        case setCurrentOverlay(CurrentOverlay?)
        case showAboutButtonTapped

        case groups(GroupsFeature.Action)
        case lecturers(LecturersFeature.Action)
        case about(AboutFeature.Action)
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case let .setCurrentSelection(value):
                state.currentSelection = value
                return .none

            case let .setCurrentOverlay(value):
                state.currentOverlay = value
                return .none

            case .showAboutButtonTapped:
                state.currentOverlay = .about
                return .none

            case let .handleDeeplink(url):
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
}
