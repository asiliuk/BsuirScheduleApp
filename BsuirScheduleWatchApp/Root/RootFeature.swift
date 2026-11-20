import Foundation
import ComposableArchitecture

@Reducer
struct RootFeature {
    @ObservableState
    struct State {
        var groups = GroupsFeature.State()
        var content = ContentFeature.State()
    }

    enum Action {
        case groups(GroupsFeature.Action)
        case content(ContentFeature.Action)
    }

    var body: some Reducer<State, Action> {
        Scope(\.groups, action: \.groups) {
            GroupsFeature()
        }

        Scope(\.content, action: \.content) {
            ContentFeature()
        }
    }
}
