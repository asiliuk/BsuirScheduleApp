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
        var subtitle: String?
        var mark: MarkedScheduleRowFeature.State
        var backedByRealGroup: Bool

        init(
            groupName: String,
            subtitle: String? = nil,
            backedByRealGroup: Bool = false
        ) {
            self.groupName = groupName
            self.subtitle = subtitle
            self.mark = MarkedScheduleRowFeature.State(source: .group(name: groupName))
            self.backedByRealGroup = backedByRealGroup
        }

        init(group: StudentGroup) {
            self.init(
                groupName: group.name,
                subtitle: [
                    group.faculty,
                    group.speciality,
                    group.course.map { String(localized: "screen.groups.row.course\($0.description)") }
                ]
                .compacted()
                .filter { !$0.isEmpty }
                .joined(separator: " · "),
                backedByRealGroup: true
            )
        }
    }

    public enum Action: Equatable {
        case mark(MarkedScheduleRowFeature.Action)
    }

    public var body: some ReducerOf<Self> {
        Scope(state: \.mark, action: \.mark) {
            MarkedScheduleRowFeature()
        }
    }
}
