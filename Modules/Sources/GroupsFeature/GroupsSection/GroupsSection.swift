import Foundation
import SwiftUI
import BsuirApi
import ComposableArchitecture
import IdentifiedCollections

public struct GroupsSection: Reducer {
    public struct State: Identifiable, Equatable {
        public var id: String { title }
        public let title: String
        public var groupRows: IdentifiedArrayOf<GroupsRow.State>

        init?(title: String, groupNames: [String]) {
            guard !groupNames.isEmpty else { return nil }
            self.title = title
            self.groupRows = IdentifiedArray(uniqueElements: groupNames.map(GroupsRow.State.init(groupName:)))
        }
    }

    @CasePathable
    public enum Action: Equatable {
        case groupRows(IdentifiedActionOf<GroupsRow>)
    }

    public var body: some ReducerOf<Self> {
        EmptyReducer()
            .forEach(\.groupRows, action: \.groupRows) {
                GroupsRow()
            }
    }
}
