import Foundation
import Combine
import ScheduleCore
import Collections


final class FavoriteServiceMock {
    let _groupNames: CurrentValueSubject<OrderedSet<String>, Never>
    let _lecturerIds: CurrentValueSubject<OrderedSet<Int>, Never>
    var _freeLoveHighScore: Int

    init(
        groupNames: OrderedSet<String> = [],
        lecturerIds: OrderedSet<Int> = [],
        freeLoveHighScore: Int = 0
    ) {
        _groupNames = CurrentValueSubject(groupNames)
        _lecturerIds = CurrentValueSubject(lecturerIds)
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

    var freeLoveHighScore: Int {
        get { _freeLoveHighScore }
        set { _freeLoveHighScore = newValue }
    }
}
