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
            WhatsNew.Feature(
                image: .init(systemName: "rectangle.portrait.bottomthird.inset.filled", foregroundColor: .primary),
                localizedTitle: "screen.settings.whatsNew.3_1.pairDetails.title",
                localizedSubtitle: "screen.settings.whatsNew.3_1.pairDetails.subtitle"
            ),
            WhatsNew.Feature(
                image: .init(systemName: "road.lanes", foregroundColor: .purple),
                localizedTitle: "screen.settings.whatsNew.3_1.roadmap.title",
                localizedSubtitle: "screen.settings.whatsNew.3_1.roadmap.subtitle"
            ),
        ],
        primaryAction: .init(localizedTitle: "screen.settings.whatsNew.button.gotIt")
    )
}
