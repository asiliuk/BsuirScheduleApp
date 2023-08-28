import Foundation
import WhatsNewKit

extension WhatsNew {
    static let version300 = WhatsNew(
        version: "3.0.0",
        title: "v3.0",
        features: [
            WhatsNew.Feature(
                image: .init(systemName: "sun.haze", foregroundColor: .orange),
                localizedTitle: "screen.settings.whatsNew.3_0.freshStart.title",
                localizedSubtitle: "screen.settings.whatsNew.3_0.freshStart.subtitle"
            ),
            WhatsNew.Feature(
                image: .init(systemName: "pin.fill", foregroundColor: .red),
                localizedTitle: "screen.settings.whatsNew.3_0.pin.title",
                localizedSubtitle: "screen.settings.whatsNew.3_0.pin.subtitle"
            ),
            WhatsNew.Feature(
                image: .init(systemName: "flame.fill", foregroundColor: .purple),
                localizedTitle: "screen.settings.whatsNew.3_0.subscription.title",
                localizedSubtitle: "screen.settings.whatsNew.3_0.subscription.subtitle"
            ),
            WhatsNew.Feature(
                image: .init(systemName: "app.gift", foregroundColor: .indigo),
                localizedTitle: "screen.settings.whatsNew.3_0.appIcons.title",
                localizedSubtitle: "screen.settings.whatsNew.3_0.appIcons.subtitle"
            ),
            WhatsNew.Feature(
                image: .init(systemName: "sparkles.rectangle.stack", foregroundColor: .yellow),
                localizedTitle: "screen.settings.whatsNew.3_0.meta.title",
                localizedSubtitle: "screen.settings.whatsNew.3_0.meta.subtitle"
            ),
        ],
        primaryAction: .init(title: "Got it")
    )
}
