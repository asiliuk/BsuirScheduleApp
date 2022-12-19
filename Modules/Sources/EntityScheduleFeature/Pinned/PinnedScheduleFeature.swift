import Foundation
import Favorites
import ComposableArchitecture

public struct PinnedScheduleFeature: ReducerProtocol {
    public enum State: Equatable {
        case group(GroupScheduleFeature.State)
        case lector(LectorScheduleFeature.State)

        public init(pinned: PinnedSchedule) {
            switch pinned {
            case let .group(groupName):
                self = .group(.init(groupName: groupName))
            case .lector(let lector):
                self = .lector(.init(lector: lector))
            }
        }
    }

    public enum Action: Equatable {
        case group(GroupScheduleFeature.Action)
        case lector(LectorScheduleFeature.Action)
    }

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        EmptyReducer()
            .ifCaseLet(/State.group, action: /Action.group) {
                GroupScheduleFeature()
            }
            .ifCaseLet(/State.lector, action: /Action.lector) {
                LectorScheduleFeature()
            }
    }
}

extension PinnedScheduleFeature.State {
    public mutating func reset() {
        try? (/Self.group).modify(&self) { $0.schedule.reset() }
        try? (/Self.lector).modify(&self) { $0.schedule.reset() }
    }
}
