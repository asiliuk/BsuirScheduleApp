import Foundation
import BsuirApi

final class AllFavoritesScreen: ObservableObject {
    var isEmpty: Bool { groups.isEmpty && lecturers.isEmpty }
    @Published private(set) var groups: [AllGroupsScreenGroup] = []
    @Published private(set) var lecturers: [AllLecturersScreenLecturer] = []

    init(requestManager: RequestsManager, favorites: FavoritesContainer) {
        self.favorites = favorites
        self.requestManager = requestManager
        favorites.$groups.map { $0.value.map(AllGroupsScreenGroup.init) }.assign(to: &$groups)
        favorites.$lecturers.map { $0.value.map(AllLecturersScreenLecturer.init) }.assign(to: &$lecturers)
    }

    func screen(for group: AllGroupsScreenGroup) -> ScheduleScreen {
        .group(group.group, favorites: favorites, requestManager: requestManager)
    }

    func screen(for lecturer: AllLecturersScreenLecturer) -> ScheduleScreen {
        .lecturer(lecturer.employee, favorites: favorites, requestManager: requestManager)
    }

    private let favorites: FavoritesContainer
    private let requestManager: RequestsManager
}
