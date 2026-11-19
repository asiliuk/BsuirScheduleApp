import Foundation
import ComposableArchitecture
import ScheduleFeature

extension GroupsFeature.State {
    /// Reset navigation and inner state
    public mutating func reset() {
        if !path.isEmpty {
            return path = StackState()
        }

        groups.modify(\.loaded) { $0.reset() }
    }

    /// Present group schedule screen on the stack
    ///
    /// Defers presentation until groups list appears.
    /// Checks stack for already presented schedule screen.
    mutating public func openGroup(
        named name: String,
        displayType: ScheduleDisplayType = .continuous
    ) {
        // Proceed only if component was presented and we could present groups immediately
        // otherwise defer group presentation til moment component was loaded
        guard groupPresentationMode == .immediate else {
            groupPresentationMode = .deferred(name, displayType: displayType)
            return
        }

        if selectedGroup?.groupName == name {
            // Switch schedule display type if screen already presented
            path.removeAll()
            selectedGroup?.schedule.switchDisplayType(displayType)
        } else {
            // Present group screen
            groups.modify(\.loaded) { $0.reset() }
            presentGroup(name, displayType: displayType)
        }
    }

    /// Checks if presentation mode has deferred group and presents it and switch mode to immediate
    mutating func presentDeferredGroupIfNeeded() {
        if case let .deferred(groupName, displayType) = groupPresentationMode {
            presentGroup(groupName, displayType: displayType)
        }
        groupPresentationMode = .immediate
    }

    /// Present group schedule screen on the stack
    mutating func presentGroup(_ groupName: String, displayType: ScheduleDisplayType = .continuous) {
        path.removeAll()
        selectedGroup = .init(groupName: groupName, scheduleDisplayType: displayType)
    }
}
