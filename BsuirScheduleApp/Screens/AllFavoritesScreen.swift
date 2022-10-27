import Foundation
import BsuirApi
import Favorites

final class AllFavoritesScreen: ObservableObject {
    enum Selection {
        case group(AllGroupsScreenGroup)
        case lecturer(AllLecturersScreenLecturer)
    }

    @Published private(set) var groups: [AllGroupsScreenGroup] = []
    @Published private(set) var lecturers: [AllLecturersScreenLecturer] = []
    @Published var selection: Selection?

    init(requestManager: RequestsManager, favorites: FavoritesContainer) {
        self.favorites = favorites
        self.requestManager = requestManager

        favorites.groups
            .map { $0.map(AllGroupsScreenGroup.init) }
            .removeDuplicates()
            .assign(to: &$groups)

        favorites.lecturers
            .map { $0.map(AllLecturersScreenLecturer.init) }
            .removeDuplicates()
            .assign(to: &$lecturers)

        selection = groups.first.map(Selection.group) ?? lecturers.first.map(Selection.lecturer)
    }

    func screen(for selection: Selection) -> ScheduleScreen {
        switch selection {
        case .group(let group):
            return screen(for: group)
        case .lecturer(let lecturer):
            return screen(for: lecturer)
        }
    }

    private func screen(for group: AllGroupsScreenGroup) -> ScheduleScreen {
        .group(group.group, favorites: favorites, requestManager: requestManager)
    }

    private func screen(for lecturer: AllLecturersScreenLecturer) -> ScheduleScreen {
        .lecturer(lecturer.employee, favorites: favorites, requestManager: requestManager)
    }

    private let favorites: FavoritesContainer
    private let requestManager: RequestsManager
}

extension AllFavoritesScreen.Selection: Identifiable {
    enum ID: Hashable {
        case group(AllGroupsScreenGroup.ID)
        case lecturer(AllLecturersScreenLecturer.ID)
    }

    var id: ID {
        switch self {
        case let .group(group):
            return .group(group.id)
        case let .lecturer(lecturer):
            return .lecturer(lecturer.id)
        }
    }
}
