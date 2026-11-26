import Foundation
import BsuirApi
import ComposableArchitecture
import Favorites
import ScheduleCore

@Reducer
struct LoadedGroupsFeature {
    @ObservableState
    struct State {
        @SharedReader(.pinnedSchedule) private var pinnedSchedule
        @SharedReader(.favoriteGroupNames) private var favoriteGroupNames

        var pinnedGroup: StudentGroup? {
            guard let name = pinnedSchedule.source?.groupName else { return nil }
            return groups[id: name]
        }

        var favoriteGroups: [StudentGroup] {
            favoriteGroupNames.compactMap { groups[id: $0] }
        }

        let groups: IdentifiedArray<String, StudentGroup>

        init(groups: [StudentGroup]) {
            self.groups = IdentifiedArray(uniqueElements: groups, id: \.name)
        }
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
