import Foundation
import ComposableArchitecture
import ScheduleFeature

extension GroupsFeatureV2.State {
    /// Reset navigation and inner state
    public mutating func reset() {
        if !path.isEmpty {
            return path = StackState()
        }

        if search.reset() {
            return
        }

        if groups.loaded?.isOnTop == false {
            groups.loaded?.isOnTop = true
        }
    }

    mutating func presentGroup(_ groupName: String, displayType: ScheduleDisplayType = .continuous) {
        path = StackState([.group(.init(groupName: groupName, scheduleDisplayType: displayType))])
    }
}
