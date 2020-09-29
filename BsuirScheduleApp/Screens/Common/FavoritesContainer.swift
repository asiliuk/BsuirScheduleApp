import Foundation
import BsuirApi

final class FavoritesContainer {
    @Published var groups: FavoritesValue<Group>
    @Published var lecturers: FavoritesValue<Employee>

    init(storage: UserDefaults) {
        self.groups = FavoritesValue(storage: storage, key: "favorite-groups")
        self.lecturers = FavoritesValue(storage: storage, key: "favorite-lecturers")
    }
}

struct FavoritesValue<F: Codable & Equatable> {
    private(set) var value: [F] {
        didSet { save(value) }
    }

    init(storage: UserDefaults, key: String) {
        self.storage = storage
        self.key = key
        self.value = []
        self.value = self.fetch()
    }

    mutating func toggle(_ favorite: F) {
        if value.contains(favorite) {
            value.removeAll(where: { $0 == favorite })
        } else {
            value.append(favorite)
        }
    }

    private func save(_ favorites: [F]) {
        storage.set(try? encoder.encode(favorites), forKey: key)
    }

    private func fetch() -> [F] {
        guard
            let data = storage.data(forKey: key),
            let favorites = try? decoder.decode([F].self, from: data)
        else { return [] }
        return favorites
    }

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let storage: UserDefaults
    private let key: String
}
