import Foundation
import WhatsNewKit
import BsuirUI
import Dependencies

extension WhatsNew {
    static let version340 = WhatsNew(
        version: "3.4.0",
        title: "v3.4",
        features: [
            WhatsNew.Feature(
                image: .init(systemName: "arrow.triangle.2.circlepath.icloud", foregroundColor: .gray),
                localizedTitle: "screen.settings.whatsNew.3_4.iCloud.title",
                localizedSubtitle: "screen.settings.whatsNew.3_4.iCloud.subtitle"
            ),
            WhatsNew.Feature(
                image: .init(systemName: "swift", foregroundColor: .orange),
                localizedTitle: "screen.settings.whatsNew.3_4.observationTools.title",
                localizedSubtitle: "screen.settings.whatsNew.3_4.observationTools.subtitle"
            ),
        ],
        primaryAction: .init(localizedTitle: "screen.settings.whatsNew.button.gotIt")
    )
}
