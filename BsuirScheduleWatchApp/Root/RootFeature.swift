import Foundation
import ComposableArchitecture

@Reducer
struct RootFeature {
    @ObservableState
    struct State {
        var pinned = PinnedFeature.State()
        var groups = GroupsFeature.State()
        var lecturers = LecturersFeature.State()
        var content = ContentFeature.State()
    }

    enum Action {
        case pinned(PinnedFeature.Action)
        case groups(GroupsFeature.Action)
        case lecturers(LecturersFeature.Action)
        case content(ContentFeature.Action)
    }

    var body: some Reducer<State, Action> {
        Scope(\.pinned, action: \.pinned) {
            PinnedFeature()
        }

        Scope(\.groups, action: \.groups) {
            GroupsFeature()
        }

        Scope(\.lecturers, action: \.lecturers) {
            LecturersFeature()
        }

        Scope(\.content, action: \.content) {
            ContentFeature()
        }
    }
}
