import Foundation
import ComposableArchitecture
import EntityScheduleFeature
import ScheduleFeature

extension GroupsFeature.State {
    /// Reset navigation and inner state
    public mutating func reset() {
        if !path.isEmpty {
            return path = StackState()
        }

        if search.reset() {
            return
        }

        if !isOnTop {
            return isOnTop = true
        }
    }

    /// Open schedule screen for group.
    mutating public func openGroup(named name: String, displayType: ScheduleDisplayType = .continuous) {
        // Proceed only if component was presented and we could present groups immediately
        // otherwise defer group presentation til moment component was loaded
        guard groupPresentationMode == .immediate else {
            groupPresentationMode = .deferred(name, displayType: displayType)
            return
        }

        if path.count == 1,
           let id = path.ids.last,
           case let .group(state) = path.last,
           state.groupName == name
        {
            path[id: id, case: /EntityScheduleFeature.State.group]?.schedule.switchDisplayType(displayType)
            return
        }
        search.reset()
        presentGroup(name, displayType: displayType)
    }


    /// Checks if presentation mode has deferred group and presents it and switch mode to immediate
    mutating func presentDeferredGroupIfNeeded() {
        if case let .deferred(groupName, displayType) = groupPresentationMode {
            presentGroup(groupName, displayType: displayType)
        }
        groupPresentationMode = .immediate
    }

    mutating func presentGroup(_ groupName: String?, displayType: ScheduleDisplayType = .continuous) {
        guard let groupName else { return }
        path = StackState([.group(.init(groupName: groupName, scheduleDisplayType: displayType))])
    }
}
