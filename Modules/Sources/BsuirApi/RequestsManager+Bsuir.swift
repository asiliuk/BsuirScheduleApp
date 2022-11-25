import Foundation

extension RequestsManager {
    public static func iisBsuir(
        session: URLSession = .shared,
        cacheDirectory: URL? = FileManager.default.sharedContainerURL
    ) -> RequestsManager {
        return RequestsManager(
            base: "https://iis.bsuir.by/api",
            session: session,
            decoder: .bsuirDecoder,
            cache: ExpiringCache(
                expiration: 3600 * 24 * 7,
                memoryCapacity: Int(1e7),
                diskCapacity: Int(1e7),
                diskPath: cacheDirectory?.path
            )
        )
    }
}

extension FileManager {
    public var sharedContainerURL: URL? {
        containerURL(forSecurityApplicationGroupIdentifier: "group.asiliuk.shared.schedule")
    }
}

// MARK: - Decoding

extension JSONDecoder {
    static let bsuirDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return decoder
    }()
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
}
