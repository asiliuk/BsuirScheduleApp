import Foundation
import BsuirApi
import Combine

public protocol FavoritesContainerProtocol {
    var groups: AnyPublisher<[StudentGroup], Never> { get }
    func toggle(group: StudentGroup)
    
    var lecturers: AnyPublisher<[Employee], Never> { get }
    func toggle(lecturer: Employee)
}

public final class FavoritesContainer {
    @Published private var groupsStorage: FavoritesValue<StudentGroup>
    @Published private var lecturersStorage: FavoritesValue<Employee>
    
    public var isEmpty: Bool {
        groupsStorage.value.isEmpty && lecturersStorage.value.isEmpty
    }

    public init(storage: UserDefaults) {
        self.groupsStorage = FavoritesValue(storage: storage, key: "favorite-groups")
        self.lecturersStorage = FavoritesValue(storage: storage, key: "favorite-lecturers")
    }
}

extension FavoritesContainer: FavoritesContainerProtocol {
    public var groups: AnyPublisher<[BsuirApi.StudentGroup], Never> {
        $groupsStorage.map(\.value).eraseToAnyPublisher()
    }
    
    public func toggle(group: StudentGroup) {
        groupsStorage.toggle(group)
    }
    
    public var lecturers: AnyPublisher<[Employee], Never> {
        $lecturersStorage.map(\.value).eraseToAnyPublisher()
    }
    
    public func toggle(lecturer: Employee) {
        lecturersStorage.toggle(lecturer)
    }
}
