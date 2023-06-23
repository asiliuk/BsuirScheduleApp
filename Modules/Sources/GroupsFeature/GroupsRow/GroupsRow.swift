import Foundation
import BsuirApi
import ScheduleFeature
import ComposableArchitecture

public struct GroupsRow: ReducerProtocol {
    public struct State: Identifiable, Equatable {
        public var id: String { groupName }
        public let groupName: String

        var title: String { groupName }
        var mark: MarkedScheduleFeature.State

        init(groupName: String) {
            self.groupName = groupName
            self.mark = .init(source: .group(name: groupName))
        }
    }

    public enum Action: Equatable {
        case rowTapped
        case mark(MarkedScheduleFeature.Action)
    }

    public var body: some ReducerProtocolOf<Self> {
        Scope(state: \.mark, action: /Action.mark) {
            MarkedScheduleFeature()
        }
    }
}
