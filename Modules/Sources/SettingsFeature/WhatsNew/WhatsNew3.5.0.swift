import Foundation
import WhatsNewKit
import BsuirUI
import Dependencies

extension WhatsNew {
    static let version350 = WhatsNew(
        version: "3.5.0",
        title: "v3.5",
        features: [
            WhatsNew.Feature(
                image: .init(systemName: "paintbrush", foregroundColor: .blue),
                localizedTitle: "screen.settings.whatsNew.3_5.ios26Design.title",
                localizedSubtitle: "screen.settings.whatsNew.3_5.ios26Design.subtitle"
            ),
            WhatsNew.Feature(
                image: .init(systemName: "rectangle.split.3x1", foregroundColor: .indigo),
                localizedTitle: "screen.settings.whatsNew.3_5.ipadLayout.title",
                localizedSubtitle: "screen.settings.whatsNew.3_5.ipadLayout.subtitle"
            ),
            WhatsNew.Feature(
                image: .init(systemName: "shield.lefthalf.filled", foregroundColor: .green),
                localizedTitle: "screen.settings.whatsNew.3_5.safeIcons.title",
                localizedSubtitle: "screen.settings.whatsNew.3_5.safeIcons.subtitle"
            ),
            WhatsNew.Feature(
                image: .init(systemName: "speedometer", foregroundColor: .orange),
                localizedTitle: "screen.settings.whatsNew.3_5.schedulePerf.title",
                localizedSubtitle: "screen.settings.whatsNew.3_5.schedulePerf.subtitle"
            ),
        ],
        primaryAction: .init(localizedTitle: "screen.settings.whatsNew.button.gotIt")
    )
}
