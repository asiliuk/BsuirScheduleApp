import Foundation
import BsuirApi
import ScheduleFeature
import ComposableArchitecture

@Reducer
public struct GroupsRow {
    @ObservableState
    public struct State: Identifiable, Equatable {
        public var id: String { groupName }
        public let groupName: String

        var title: String { groupName }
        var mark: MarkedScheduleRowFeature.State

        init(groupName: String) {
            self.groupName = groupName
            self.mark = MarkedScheduleRowFeature.State(source: .group(name: groupName))
        }
    }

    public enum Action: Equatable {
        case rowTapped
        case mark(MarkedScheduleRowFeature.Action)
    }

    public var body: some ReducerOf<Self> {
        Scope(state: \.mark, action: \.mark) {
            MarkedScheduleRowFeature()
        }
    }
}
