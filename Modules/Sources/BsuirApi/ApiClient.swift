import Foundation
import Dependencies
@preconcurrency import URLRouting

public struct ApiClient: Sendable {
    public var clearCache: @Sendable () -> Void
    private var client: URLRoutingClient<CachingRoute<IISRoute>>

    init(client: URLRoutingClient<CachingRoute<IISRoute>>, clearCache: @Sendable @escaping () -> Void) {
        self.client = client
        self.clearCache = clearCache
    }
}

// MARK: - API

extension ApiClient {
    public func groups(ignoreCache: Bool = false) async throws -> [StudentGroup] {
        try await request(route: .studentGroups, ignoreCache: ignoreCache)
    }

    public func lecturers(ignoreCache: Bool = false) async throws -> [Employee] {
        try await request(route: .employees, ignoreCache: ignoreCache)
    }

    public func groupSchedule(name: String, ignoreCache: Bool = false) async throws -> StudentGroup.Schedule {
        try await request(route: .groupSchedule(groupName: name), ignoreCache: ignoreCache)
    }

    public func lecturerSchedule(urlId: String, ignoreCache: Bool = false) async throws -> Employee.Schedule {
        try await request(route: .employeeSchedule(urlId: urlId), ignoreCache: ignoreCache)
    }

    public func week() async throws -> Int {
        try await request(route: .week, ignoreCache: true)
    }

    private func request<Value: Decodable>(route: IISRoute, ignoreCache: Bool) async throws -> Value {
        try await client.decodedResponse(for: .init(ignoreCache: ignoreCache, base: route)).value
    }
}

// MARK: - Live

extension ApiClient {
    public static let live = {
        let cachePath = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.asiliuk.shared.schedule")?
            .path

        let cache = ExpiringCache(
            expiration: 3600 * 24 * 7,
            memoryCapacity: Int(1e7),
            diskCapacity: Int(1e7),
            diskPath: cachePath
        )

        return ApiClient(
            client: .liveCaching(
                in: cache,
                router: iisRouter.baseURL(URL.iisApi.absoluteString),
                decoder: .bsuirDecoder
            ),
            clearCache: { cache.removeAllCachedResponses() }
        )
    }()
}

// MARK: - Dependency

extension DependencyValues {
    public var apiClient: ApiClient {
        get { self[ApiClientKey.self] }
        set { self[ApiClientKey.self] = newValue }
    }
}

private enum ApiClientKey: DependencyKey {
    static let liveValue = ApiClient.live
    static let testValue = ApiClient(client: .failing, clearCache: {})
}
