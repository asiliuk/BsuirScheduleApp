import Foundation

extension UserDefaults {
    public func persistedArray<Element>(
        of elementType: Element.Type = Element.self,
        forKey key: String
    ) -> PersistedValue<[Element]?> {
        PersistedValue(
            get: { self.array(forKey: key) as? [Element] },
            set: { self.set($0, forKey: key) }
        )
    }

    public func persistedString(forKey key: String) -> PersistedValue<String?> {
        PersistedValue(
            get: { self.string(forKey: key) },
            set: { self.set($0, forKey: key) }
        )
    }

    public func persistedInteger(forKey key: String) -> PersistedValue<Int> {
        PersistedValue(
            get: { self.integer(forKey: key) },
            set: { self.set($0, forKey: key) }
        )
    }

    public func persistedCodable<Value: Codable>(
        _ value: Value.Type = Value.self,
        forKey key: String
    ) -> PersistedValue<Value?> {
        PersistedValue(
            get: { self.data(forKey: key).flatMap { try? JSONDecoder().decode(Value.self, from: $0) } },
            set: { self.set($0.flatMap { try? JSONEncoder().encode($0) }, forKey: key) }
        )
    }
}
