import Foundation
import BsuirApi
import Combine

public protocol FavoritesContainerProtocol {
    var groupNames: AnyPublisher<[String], Never> { get }
    func toggle(groupNamed: String)
    
    var lecturers: AnyPublisher<[Employee], Never> { get }
    func toggle(lecturer: Employee)
}

public final class FavoritesContainer {
    @Published private var legacyGroupsStorage: FavoritesValue<StudentGroup>
    @Published private var groupNamesStorage: FavoritesValue<String>
    @Published private var lecturersStorage: FavoritesValue<Employee>
    
    public var isGroupsEmpty: Bool {
        groupNamesStorage.value.isEmpty
    }

    public var isLecturersEmpty: Bool {
        lecturersStorage.value.isEmpty
    }

    public init(storage: UserDefaults) {
        self.legacyGroupsStorage = FavoritesValue(storage: storage, key: "favorite-groups")
        self.groupNamesStorage = FavoritesValue(storage: storage, key: "favorite-group-names")
        self.lecturersStorage = FavoritesValue(storage: storage, key: "favorite-lecturers")
    }

    public func migrateIfNeeded() {
        let legacyGroups = legacyGroupsStorage.value

        guard !legacyGroups.isEmpty else { return }
        legacyGroupsStorage.value = []
        groupNamesStorage.value = legacyGroups.map(\.name)
    }
}

extension FavoritesContainer: FavoritesContainerProtocol {
    public var groupNames: AnyPublisher<[String], Never> {
        $groupNamesStorage.map(\.value).eraseToAnyPublisher()
    }
    
    public func toggle(groupNamed groupName: String) {
        groupNamesStorage.toggle(groupName)
    }
    
    public var lecturers: AnyPublisher<[Employee], Never> {
        $lecturersStorage.map(\.value).eraseToAnyPublisher()
    }
    
    public func toggle(lecturer: Employee) {
        lecturersStorage.toggle(lecturer)
    }
}
