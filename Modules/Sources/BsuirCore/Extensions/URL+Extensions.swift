import Foundation

// MARK: - Constants

extension URL {
    public static let iisApi = URL(string: "https://iis.bsuir.by/api")!
    public static let github = URL(string: "https://github.com/asiliuk/BsuirScheduleApp")!
    public static let telegram = URL(string: "https://t.me/bsuirschedule")!
    public static let appStoreReview = URL(string: "https://apps.apple.com/us/app/bsuir-schedule/id944151090?action=write-review")!
    public static let appStoreSubscriptions = URL(string: "https://apps.apple.com/account/subscriptions")!

    public static let privacyPolicy = URL(string: "https://asiliuk.github.io/BsuirScheduleApp/static/privacy-policy")!
    public static let termsAndConditions = URL(string: "https://asiliuk.github.io/BsuirScheduleApp/static/terms-and-conditions")!
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
