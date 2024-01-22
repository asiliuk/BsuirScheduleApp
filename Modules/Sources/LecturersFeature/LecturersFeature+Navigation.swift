import Foundation
import ComposableArchitecture
import BsuirApi
import EntityScheduleFeature
import ScheduleFeature

extension LecturersFeature.State {
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

    /// Open schedule screen for lector.
    public mutating func openLector(_ lector: Employee, displayType: ScheduleDisplayType) {
        if path.count == 1,
           let id = path.ids.last,
           case let .lector(state) = path.last,
           state.lector == lector
        {
            path[id: id, case: /EntityScheduleFeature.State.lector]?.schedule.switchDisplayType(displayType)
            return
        }
        search.reset()
        presentLector(lector, displayType: displayType)
        lectorToOpen = nil
    }

    /// Open schedule screen for lector.
    public mutating func openLector(id: Int, displayType: ScheduleDisplayType = .continuous) {
        if let lector = loadedLecturers?[id: id] {
            openLector(lector, displayType: displayType)
        } else {
            lectorToOpen = .init(id: id, displayType: displayType)
        }
    }

    /// Check if we have model for lector we were trying to open if so open its schedule.
    mutating func openLectorIfNeeded() {
        guard let lectorToOpen else { return }
        openLector(id: lectorToOpen.id, displayType: lectorToOpen.displayType)
    }

    mutating func presentLector(_ lector: Employee?, displayType: ScheduleDisplayType = .continuous) {
        guard let lector else { return }
        path = StackState([.lector(.init(lector: lector, scheduleDisplayType: displayType))])
    }
}
