import Foundation
import Favorites
import ScheduleCore

extension AppFeature.State {
    mutating func handleInitialSelection(
        favorites: FavoritesService,
        pinnedScheduleService: PinnedScheduleService
    ) {
        // TODO: !!! REMOVE THIS !!!
        return selection = .groupsV2

        if let pinnedSchedule = pinnedScheduleService.currentSchedule() {
            selection = .pinned
            pinnedTab.show(pinned: pinnedSchedule)
            return
        }

        if let groupName = favorites.currentGroupNames.first {
            selection = .groups
            groups.openGroup(named: groupName)
            return
        }

        if let lectorId = favorites.currentLectorIds.first {
            selection = .lecturers
            lecturers.openLector(id: lectorId)
            return
        }
    }

    mutating func updateSelection(_ newValue: CurrentSelection) {
        guard newValue == selection else {
            selection = newValue
            return
        }

        // Handle tap on already selected tab
        switch newValue {
        case .pinned:
            pinnedTab.reset()
        case .groups:
            groups.reset()
        case .groupsV2:
            groupsV2.reset()
        case .lecturers:
            lecturers.reset()
        case .settings:
            settings.reset()
        }
    }
}
