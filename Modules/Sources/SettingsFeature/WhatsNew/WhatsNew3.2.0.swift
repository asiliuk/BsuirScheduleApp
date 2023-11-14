import Foundation
import WhatsNewKit
import BsuirUI
import Dependencies

extension WhatsNew {
    static let version320 = WhatsNew(
        version: "3.2.0",
        title: "v3.2",
        features: [
            WhatsNew.Feature(
                image: .init(systemName: "square.text.square", foregroundColor: {
                    @Dependency(\.pairFormDisplayService) var pairFormDisplayService
                    return pairFormDisplayService.color(for: .exam).color
                }()),
                localizedTitle: "screen.settings.whatsNew.3_2.examsWidgets.title",
                localizedSubtitle: "screen.settings.whatsNew.3_2.examsWidgets.subtitle"
            ),
            WhatsNew.Feature(
                image: .init(systemName: "person.crop.square", foregroundColor: .secondary),
                localizedTitle: "screen.settings.whatsNew.3_2.subgroupFilter.title",
                localizedSubtitle: "screen.settings.whatsNew.3_2.subgroupFilter.subtitle"
            ),
        ],
        primaryAction: .init(localizedTitle: "screen.settings.whatsNew.button.gotIt")
    )
}
