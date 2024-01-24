import Foundation
import BsuirCore
import BsuirApi
import ScheduleCore
import Collections
import Combine
import Dependencies

public final class LiveFavoritesService {
    private let widgetService: WidgetService
    private let storage: UserDefaults
    private let legacyStorage: UserDefaults

    // MARK: - Legacy
    private lazy var legacyGroupsStorage = legacyStorage
        .persistedData(forKey: "favorite-groups")
        .codable([StudentGroup].self)

    private lazy var legacyGroupNamesStorage = legacyStorage
        .persistedData(forKey: "favorite-group-names")
        .codable([String].self)

    private lazy var legacyLecturersStorage = legacyStorage
        .persistedData(forKey: "favorite-lecturers")
        .codable([Employee].self)

    // MARK: - Storage
    private lazy var groupNamesStorage = storage
        .persistedArray(of: String.self, forKey: "favorite-group-names")
        .toOrderedSet()
        .unwrap(withDefault: [])
        .withPublisher()

    private lazy var lecturerIDsStorage = storage
        .persistedArray(of: Int.self, forKey: "favorite-lector-ids")
        .toOrderedSet()
        .unwrap(withDefault: [])
        .withPublisher()

    private lazy var freeLoveHighScoreStorage = storage
        .persistedInteger(forKey: "free-love-hich-score")

    init(
        storage: UserDefaults,
        legacyStorage: UserDefaults,
        widgetService: WidgetService
    ) {
        self.storage = storage
        self.legacyStorage = legacyStorage
        self.widgetService = widgetService
        migrateIfNeeded()
    }

    private func migrateIfNeeded() {
        let legacyGroups = legacyGroupsStorage.value
        if let legacyGroups, !legacyGroups.isEmpty {
            legacyGroupsStorage.value = nil
            groupNamesStorage.persisted.value = OrderedSet(legacyGroups.map(\.name))
        }

        // Migrated from storing array as JSON Data to using normal UserDefaults api
        let legacyGroupNames = legacyGroupNamesStorage.value
        if let legacyGroupNames, !legacyGroupNames.isEmpty {
            legacyGroupNamesStorage.value = nil
            groupNamesStorage.persisted.value = OrderedSet(legacyGroupNames)
        }

        let legacyLecturers = legacyLecturersStorage.value
        if let legacyLecturers, !legacyLecturers.isEmpty {
            legacyLecturersStorage.value = nil
            lecturerIDsStorage.persisted.value = OrderedSet(legacyLecturers.map(\.id))
        }
    }
}

// MARK: - FavoritesService

extension LiveFavoritesService: FavoritesService {
    public var currentGroupNames: OrderedSet<String> {
        get { groupNamesStorage.persisted.value }
        set { groupNamesStorage.persisted.value = newValue }
    }

    public var groupNames: AnyPublisher<OrderedSet<String>, Never> {
        groupNamesStorage.publisher
    }

    public var currentLectorIds: OrderedSet<Int> {
        get { lecturerIDsStorage.persisted.value }
        set { lecturerIDsStorage.persisted.value = newValue }
    }

    public var lecturerIds: AnyPublisher<OrderedSet<Int>, Never> {
        lecturerIDsStorage.publisher
    }

    public var freeLoveHighScore: Int {
        get { freeLoveHighScoreStorage.value }
        set { freeLoveHighScoreStorage.value = newValue }
    }
}

// MARK: - Helpers

private extension PersistedValue {
    func toggle<Element>(_ element: Element) where Value == OrderedSet<Element> {
        if value.contains(element) {
            value.remove(element)
        } else {
            value.append(element)
        }
    }
}
