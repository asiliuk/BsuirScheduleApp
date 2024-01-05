import Foundation
import WhatsNewKit
import BsuirUI
import Dependencies

extension WhatsNew {
    static let version330 = WhatsNew(
        version: "3.3.0",
        title: "v3.3",
        features: [
            WhatsNew.Feature(
                image: .init(systemName: "person.fill.viewfinder", foregroundColor: .orange),
                localizedTitle: "screen.settings.whatsNew.3_3.photoPreview.title",
                localizedSubtitle: "screen.settings.whatsNew.3_3.photoPreview.subtitle"
            ),
        ],
        primaryAction: .init(localizedTitle: "screen.settings.whatsNew.button.gotIt")
    )
}
