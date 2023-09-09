import Foundation
import Roadmap

struct FeatureVoterTallyAPI: FeatureVoter {
    let namespace: String
    private static let urlSession = URLSession(configuration: .ephemeral)

    /// Fetches the current count for the given feature.
    /// - Returns: The current `count`, else `0` if unsuccessful.
    func fetch(for feature: Roadmap.RoadmapFeature) async -> Int {
        do {
            let response = try await request(for: feature, endpoint: .get)
            return response.value ?? 0
        } catch {
            assertionFailure(error.localizedDescription)
            return 0
        }
    }

    /// Votes for the given feature.
    /// - Returns: The new `count` if successful.
    func vote(for feature: Roadmap.RoadmapFeature) async -> Int? {
        do {
            let response = try await request(for: feature, endpoint: .add(delta: 1))
            return response.value
        } catch {
            assertionFailure(error.localizedDescription)
            return nil
        }
    }

    /// Removes a vote for the given feature.
    /// - Returns: The new `count` if successful.
    func unvote(for feature: Roadmap.RoadmapFeature) async -> Int? {
        do {
            let response = try await request(for: feature, endpoint: .add(delta: -1))
            return response.value
        } catch {
            assertionFailure(error.localizedDescription)
            return nil
        }
    }
}

private extension FeatureVoterTallyAPI {
    enum Endpoint {
        case add(delta: Int)
        case get
    }

    struct Response: Codable {
        let value: Int?
    }

    enum RequestError: Error {
        case failedToCreateURL
    }

    func request(for feature: Roadmap.RoadmapFeature, endpoint: Endpoint) async throws -> Response {
        guard let url = url(for: feature, endpoint: endpoint) else {
            throw RequestError.failedToCreateURL
        }

        let (data, _) = try await Self.urlSession.data(from: url)
        return try JSONDecoder().decode(Response.self, from: data)
    }

    func url(for feature: Roadmap.RoadmapFeature, endpoint: Endpoint) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "tally.fly.dev"
        let path = switch endpoint {
        case .add: "add"
        case .get: "get"
        }
        components.path = "/\(path)/\(namespace)/feature-\(feature.id)"
        components.queryItems = switch endpoint {
        case .add(let delta): [URLQueryItem(name: "delta", value: String(delta))]
        case .get: nil
        }
        return components.url
    }
}
