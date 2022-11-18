import Foundation

struct FavoritesValue<F: Codable & Equatable> {
    var value: [F] {
        didSet { save(value) }
    }

    mutating func toggle(_ favorite: F) {
        if value.contains(favorite) {
            value.removeAll(where: { $0 == favorite })
        } else {
            value.append(favorite)
        }
    }
    
    init(storage: UserDefaults, key: String) {
        self.storage = storage
        self.key = key
        self.value = []
        self.value = self.fetch()
    }

    private func save(_ favorites: [F]) {
        if favorites.isEmpty {
            storage.removeObject(forKey: key)
        } else {
            storage.set(try? encoder.encode(favorites), forKey: key)
        }
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
