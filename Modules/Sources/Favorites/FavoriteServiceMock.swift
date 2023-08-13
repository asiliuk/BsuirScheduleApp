import Foundation
import Combine
import ScheduleCore
import Collections

#if DEBUG
final class FavoriteServiceMock {
    let _groupNames: CurrentValueSubject<OrderedSet<String>, Never>
    let _lecturerIds: CurrentValueSubject<OrderedSet<Int>, Never>
    let _pinnedSchedule: CurrentValueSubject<ScheduleSource?, Never>
    var _freeLoveHighScore: Int

    init(
        groupNames: OrderedSet<String> = [],
        lecturerIds: OrderedSet<Int> = [],
        pinnedSchedule: ScheduleSource? = nil,
        freeLoveHighScore: Int = 0
    ) {
        _groupNames = CurrentValueSubject(groupNames)
        _lecturerIds = CurrentValueSubject(lecturerIds)
        _pinnedSchedule = CurrentValueSubject(pinnedSchedule)
        _freeLoveHighScore = freeLoveHighScore
    }
}

// MARK: - FavoritesService

extension FavoriteServiceMock: FavoritesService {
    var currentGroupNames: OrderedSet<String> {
        get { _groupNames.value }
        set { _groupNames.value = newValue }
    }

    var groupNames: AnyPublisher<OrderedSet<String>, Never> {
        _groupNames.eraseToAnyPublisher()
    }

    var currentLectorIds: OrderedSet<Int> {
        get { _lecturerIds.value }
        set { _lecturerIds.value = newValue }
    }

    var lecturerIds: AnyPublisher<OrderedSet<Int>, Never> {
        _lecturerIds.eraseToAnyPublisher()
    }

    var currentPinnedSchedule: ScheduleSource? {
        get { _pinnedSchedule.value }
        set { _pinnedSchedule.value = newValue }
    }

    var pinnedSchedule: AnyPublisher<ScheduleCore.ScheduleSource?, Never> {
        _pinnedSchedule.eraseToAnyPublisher()
    }

    var freeLoveHighScore: Int {
        get { _freeLoveHighScore }
        set { _freeLoveHighScore = newValue }
    }
}
#endif
