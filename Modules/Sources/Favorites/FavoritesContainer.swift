import Foundation
import BsuirApi
import Combine

public final class FavoritesContainer {
    @Published private var legacyGroupsStorage: FavoritesValue<StudentGroup>
    @Published private var groupNamesStorage: FavoritesValue<String>
    @Published private var lecturersStorage: FavoritesValue<Employee>

    init(storage: UserDefaults) {
        self.legacyGroupsStorage = FavoritesValue(storage: storage, key: "favorite-groups")
        self.groupNamesStorage = FavoritesValue(storage: storage, key: "favorite-group-names")
        self.lecturersStorage = FavoritesValue(storage: storage, key: "favorite-lecturers")

        migrateIfNeeded()
    }

    private func migrateIfNeeded() {
        let legacyGroups = legacyGroupsStorage.value

        guard !legacyGroups.isEmpty else { return }
        legacyGroupsStorage.value = []
        groupNamesStorage.value = legacyGroups.map(\.name)
    }
}

// MARK: - API

extension FavoritesContainer {
    public var currentGroupNames: [String] {
        groupNamesStorage.value
    }

    public var groupNames: AnyPublisher<[String], Never> {
        $groupNamesStorage.map(\.value).eraseToAnyPublisher()
    }
    
    public func toggle(groupNamed groupName: String) {
        groupNamesStorage.toggle(groupName)
    }

    public var currentLecturers: [Employee] {
        lecturersStorage.value
    }

    public var lecturers: AnyPublisher<[Employee], Never> {
        $lecturersStorage.map(\.value).eraseToAnyPublisher()
    }
    
    public func toggle(lecturer: Employee) {
        lecturersStorage.toggle(lecturer)
    }
}
