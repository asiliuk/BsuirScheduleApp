import Foundation
import Favorites
import ScheduleCore
import ComposableArchitecture

public struct PinnedScheduleFeature: Reducer {
    public enum State: Equatable {
        case group(GroupScheduleFeature.State)
        case lector(LectorScheduleFeature.State)

        public init(pinned: ScheduleSource) {
            switch pinned {
            case let .group(groupName):
                self = .group(.init(groupName: groupName))
            case let .lector(lector):
                self = .lector(.init(lector: lector))
            }
        }
    }

    public enum Action: Equatable {
        case group(GroupScheduleFeature.Action)
        case lector(LectorScheduleFeature.Action)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
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
    public var title: String {
        switch self {
        case let .group(schedule):
            return schedule.groupName
        case let .lector(schedule):
            return schedule.lector.compactFio
        }
    }
}

extension PinnedScheduleFeature.State {
    public mutating func reset() {
        try? (/Self.group).modify(&self) { $0.schedule.reset() }
        try? (/Self.lector).modify(&self) { $0.schedule.reset() }
    }
}
