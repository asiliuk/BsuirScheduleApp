import Foundation

extension UserDefaults {
    public func persistedDictionary(
        forKey key: String
    ) -> PersistedValue<[String: Any]?> {
        PersistedValue(
            get: { self.dictionary(forKey: key) },
            set: { self.set($0, forKey: key) }
        )
    }

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

    public func persistedData(forKey key: String) -> PersistedValue<Data?> {
        PersistedValue(
            get: { self.data(forKey: key) },
            set: { self.set($0, forKey: key) }
        )
    }
}
