import Foundation
import Dependencies
import XCTestDynamicOverlay
@preconcurrency import URLRouting

public struct ApiClient: Sendable {
    public var groups: @Sendable (_ ignoreCache: Bool) async throws -> [StudentGroup]
    public var lecturers: @Sendable (_ ignoreCache: Bool) async throws -> [Employee]
    public var groupSchedule: @Sendable (_ name: String, _ ignoreCache: Bool) async throws -> StudentGroup.Schedule
    public var lecturerSchedule: @Sendable (_ urlId: String, _ ignoreCache: Bool) async throws -> Employee.Schedule
    public var week: @Sendable () async throws -> Int
    public var clearCache: @Sendable () async -> Void
}

// MARK: - Live

extension ApiClient {
    static func live(
        client: URLRoutingClient<CachingRoute<IISRoute>>,
        clearCache: @Sendable @escaping () -> Void
    ) -> ApiClient {
        @Sendable func request<Value: Decodable>(route: IISRoute, ignoreCache: Bool) async throws -> Value {
            try await client.decodedResponse(for: .init(ignoreCache: ignoreCache, base: route)).value
        }

        return ApiClient(
            groups: { ignoreCache in
                try await request(route: .studentGroups, ignoreCache: ignoreCache)
            },
            lecturers: { ignoreCache in
                try await request(route: .employees, ignoreCache: ignoreCache)
            },
            groupSchedule: { name, ignoreCache in
                try await request(route: .groupSchedule(groupName: name), ignoreCache: ignoreCache)
            },
            lecturerSchedule: { urlId, ignoreCache in
                try await request(route: .employeeSchedule(urlId: urlId), ignoreCache: ignoreCache)
            },
            week: {
                try await request(route: .week, ignoreCache: true)
            },
            clearCache: clearCache
        )
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

        return ApiClient.live(
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
    static let previewValue = ApiClient(
        groups: { _ in
            let url = Bundle.main.url(forResource: "groups", withExtension: "json")
            let data = try Data(contentsOf: url!)
            return try JSONDecoder.bsuirDecoder.decode([StudentGroup].self, from: data)
        },
        lecturers: { _ in
            let url = Bundle.main.url(forResource: "employees", withExtension: "json")
            let data = try Data(contentsOf: url!)
            return try JSONDecoder.bsuirDecoder.decode([Employee].self, from: data)
        },
        groupSchedule: { name, _ in
            guard name == "151004" else { fatalError("Unexpected group") }
            let url = Bundle.main.url(forResource: "151004", withExtension: "json")
            let data = try Data(contentsOf: url!)
            return try JSONDecoder.bsuirDecoder.decode(StudentGroup.Schedule.self, from: data)
        },
        lecturerSchedule: unimplemented("ApiClient.lecturerSchedule"),
        week: unimplemented("ApiClient.week"),
        clearCache: unimplemented("ApiClient.clearCache")
    )
}
