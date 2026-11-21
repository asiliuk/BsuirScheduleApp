import Foundation
import BsuirApi
import ComposableArchitecture

@Reducer
struct LoadedGroupsFeature {
    @ObservableState
    struct State {
        let groups: [StudentGroup]
    }

    enum Action {
        enum Delegate {
            case showGroupSchedule(String)
        }

        case rowTapped(String)
        case delegate(Delegate)
    }

    var body: some Reducer<State, Action> {
        Reduce { _, action in
            switch action {
            case .rowTapped(let name):
                return .send(.delegate(.showGroupSchedule(name)))
            case .delegate:
                return .none
            }
        }
    }
}
