import Foundation
import SwiftUI
import BsuirApi
import ComposableArchitecture
import IdentifiedCollections

public struct GroupSection: ReducerProtocol {
    public struct State: Identifiable, Equatable {
        public var id: String { title }
        public let title: String
        public var groupRows: IdentifiedArrayOf<GroupRow.State>

        init?(title: String, groupNames: [String]) {
            guard !groupNames.isEmpty else { return nil }
            self.title = title
            self.groupRows = IdentifiedArray(uniqueElements: groupNames.map(GroupRow.State.init(groupName:)))
        }
    }

    public enum Action: Equatable {
        case groupRow(id: GroupRow.State.ID, action: GroupRow.Action)
    }

    public var body: some ReducerProtocol<State, Action> {
        EmptyReducer()
            .forEach(\.groupRows, action: /Action.groupRow) {
                GroupRow()
            }
    }
}
