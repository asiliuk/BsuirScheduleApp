import Foundation

extension URL {
    public var bsr_host: String {
        guard #available(iOS 16.0, *) else { return host! }
        return host()!
    }
}

// MARK: - Constants

extension URL {
    public static let iisApi = URL(string: "https://iis.bsuir.by/api")!
    public static let github = URL(string: "https://github.com/asiliuk/BsuirScheduleApp")!
    public static let telegram = URL(string: "https://t.me/bsuirschedule")!
    public static let mastodon = URL(string: "https://indieapps.space/@BsuirSchedule")!
}

// MARK: - Github

extension URL {
    // https://github.com/octo-org/octo-repo/issues/new?title=New+bug+report&body=Describe+the+problem.
    public static func githubIssue(title: String, body: String, labels: String...) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "github.com"
        components.path = "/asiliuk/BsuirScheduleApp/issues/new"
        components.queryItems = [
            .init(name: "title", value: title),
            .init(name: "body", value: body),
            .init(name: "labels", value: labels.joined(separator: ","))
        ]
        return components.url!
    }
}
