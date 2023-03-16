import Foundation
import SwiftUI

struct FakeAdConfig {
    enum AdImage: Equatable {
        case system(String)
        case predefined(String)
    }

    let image: AdImage
    var label: LocalizedStringKey = "view.fakeAd.label"
    var title: LocalizedStringKey
    var description: LocalizedStringKey
}


extension FakeAdConfig {
    static let all: [FakeAdConfig] = [
        FakeAdConfig(
            image: .predefined("FakeAds/exams"),
            title: "view.fakeAd.exams.title",
            description: "view.fakeAd.exams.description"
        ),
    ]
}
