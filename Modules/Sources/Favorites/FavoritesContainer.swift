import Foundation
import BsuirApi
import BsuirCore
import Collections
import Combine

public final class FavoritesContainer {
    // MARK: - Legacy
    private lazy var legacyGroupsStorage = legacyStorage
        .persistedCodable([StudentGroup].self, forKey: "favorite-groups")

    private lazy var legacyGroupNamesStorage = legacyStorage
        .persistedCodable([String].self, forKey: "favorite-group-names")

    private lazy var legacyLecturersStorage = legacyStorage
        .persistedCodable([Employee].self, forKey: "favorite-lecturers")

    // MARK: - Storage
    private let storage: UserDefaults
    private let legacyStorage: UserDefaults

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

    init(storage: UserDefaults, legacyStorage: UserDefaults) {
        self.storage = storage
        self.legacyStorage = legacyStorage
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

// MARK: - API

extension FavoritesContainer {
    public var currentGroupNames: OrderedSet<String> {
        groupNamesStorage.persisted.value
    }

    public var groupNames: AnyPublisher<OrderedSet<String>, Never> {
        groupNamesStorage.publisher
    }
    
    public func toggle(groupNamed groupName: String) {
        groupNamesStorage.persisted.toggle(groupName)
    }

    public var currentLectorIds: OrderedSet<Int> {
        lecturerIDsStorage.persisted.value
    }

    public var lecturerIds: AnyPublisher<OrderedSet<Int>, Never> {
        lecturerIDsStorage.publisher
    }
    
    public func toggle(lecturerWithId id: Int) {
        lecturerIDsStorage.persisted.toggle(id)
    }
}

// MARK: - Helpers

private extension PersistedValue {
    func toOrderedSet<Element: Hashable>() -> PersistedValue<OrderedSet<Element>?> where Value == [Element]? {
        map(get: { $0.map(OrderedSet.init) }, set: { $0.map(Array.init) })
    }

    func toggle<Element>(_ element: Element) where Value == OrderedSet<Element> {
        if value.contains(element) {
            value.remove(element)
        } else {
            value.append(element)
        }
    }
}
