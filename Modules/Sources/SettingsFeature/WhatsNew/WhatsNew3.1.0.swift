import Foundation
import WhatsNewKit

extension WhatsNew {
    static let version310 = WhatsNew(
        version: "3.1.0",
        title: "v3.1",
        features: [
            WhatsNew.Feature(
                image: .init(systemName: "square.text.square", foregroundColor: .blue),
                localizedTitle: "screen.settings.whatsNew.3_1.widgets.title",
                localizedSubtitle: "screen.settings.whatsNew.3_1.widgets.subtitle"
            ),

        ],
        primaryAction: .init(localizedTitle: "screen.settings.whatsNew.button.gotIt")
    )
}
