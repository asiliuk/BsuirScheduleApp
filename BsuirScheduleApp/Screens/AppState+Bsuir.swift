import Foundation
import os.log
import BsuirApi

extension RequestsManager.Logger {

    static let osLog = Self(constructRequest: { request in
        os_log(.debug, log: .targetRequest, "%@", request.curlDescription)
    })
}

private extension OSLog {

    static let targetRequest = bsuirSchedule(category: "TargetRequest")
}

private extension URLRequest {

    var curlDescription: String {
        guard let url = url else { return "[Unknown]" }

        let body = httpBody
            .flatMap { String(data: $0, encoding: .utf8) }
            .map { "-d '\($0)'" }

        let headers = allHTTPHeaderFields?
            .map { "-H '\($0.0): \($0.1)'" }

        let components = ["curl", url.absoluteString] + ([body].compactMap { $0 }) + (headers ?? [])

        return components.joined(separator: " ")
    }
}
