import Foundation
import ComposableArchitecture
import BsuirApi
import ScheduleFeature
import EntityScheduleFeature

extension LecturersFeature.State {
    /// Reset navigation and inner state
    public mutating func reset() {
        if !path.isEmpty {
            return path = StackState()
        }

        lecturers.modify(\.loaded) { $0.reset() }
    }

    /// Open schedule screen for lector.
    public mutating func openLector(
        _ lector: Employee,
        displayType: ScheduleDisplayType
    ) {
        if selectedLector?.lector == lector {
            path.removeAll()
            selectedLector?.schedule.switchDisplayType(displayType)
        } else {
            lecturers.modify(\.loaded) { $0.reset() }
            presentLector(lector, displayType: displayType)
        }
    }

    /// Open schedule screen for lector and defer presentation if needed
    public mutating func openLector(
        id: Int,
        displayType: ScheduleDisplayType = .continuous
    ) {
        if let lector = lecturers.loaded?.lector(withId: id) {
            openLector(lector, displayType: displayType)
            lectorPresentationMode = .immediate
        } else {
            lectorPresentationMode = .deferred(id: id, displayType: displayType)
        }
    }

    /// Checks if presentation mode has deferred lector and presents it and switch mode to immediate
    mutating func presentDeferredLectorIfNeeded() {
        if case let .deferred(id, displayType) = lectorPresentationMode {
            openLector(id: id, displayType: displayType)
        } else {
            lectorPresentationMode = .immediate
        }
    }

    /// Present lector schedule on stack
    mutating func presentLector(
        _ lector: Employee?,
        displayType: ScheduleDisplayType = .continuous
    ) {
        guard let lector else { return }
        path.removeAll()
        selectedLector = LectorScheduleFeature.State(
            lector: lector,
            scheduleDisplayType: displayType
        )
    }
}
