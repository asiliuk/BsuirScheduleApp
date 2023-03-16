import Foundation
import SwiftUI

struct FakeAdConfig {
    enum AdImage: Equatable {
        case system(String)
        case predefined(String)
    }

    let image: AdImage
    var label: LocalizedStringKey = "FakeAD"
    var title: LocalizedStringKey
    var description: LocalizedStringKey
}


extension FakeAdConfig {
    static let all: [FakeAdConfig] = [
        FakeAdConfig(
            image: .system("airplane.departure"),
            title: "Hello there my fake ad",
            description: "This is description of my fake ad banner and it could be pretty long"
        )
    ]
}
