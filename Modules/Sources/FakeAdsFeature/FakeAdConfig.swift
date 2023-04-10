import Foundation
import SwiftUI

public struct FakeAdConfig: Equatable {
    public enum AdImage: Equatable {
        case text(LocalizedStringKey)
        case system(String)
        case predefined(String)
    }

    public let image: AdImage
    public var label: LocalizedStringKey
    public var title: LocalizedStringKey
    public var description: LocalizedStringKey

    public init(
        image: AdImage,
        label: LocalizedStringKey = "view.fakeAd.label",
        title: LocalizedStringKey,
        description: LocalizedStringKey
    ) {
        self.image = image
        self.label = label
        self.title = title
        self.description = description
    }
}

extension FakeAdConfig {
    public static let exams = FakeAdConfig(
        image: .predefined("FakeAds/exams"),
        title: "view.fakeAd.exams.title",
        description: "view.fakeAd.exams.description"
    )
    public static let party = FakeAdConfig(
        image: .predefined("FakeAds/party"),
        title: "view.fakeAd.party.title",
        description: "view.fakeAd.party.description"
    )
    public static let placeholder = FakeAdConfig(
        image: .system("photo.on.rectangle.angled"),
        title: "view.fakeAd.placeholder.title",
        description: "view.fakeAd.placeholder.description"
    )
}

extension FakeAdConfig {
    static let all: [FakeAdConfig] = [
        exams,
        party,
        placeholder,
    ]
}
