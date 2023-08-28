import Foundation
import WhatsNewKit

extension WhatsNew.Feature {
    init(
        image: Image,
        localizedTitle: LocalizedStringResource,
        localizedSubtitle: LocalizedStringResource
    ) {
        self.init(
            image: image,
            title: WhatsNew.Text(String(localized: localizedTitle)),
            subtitle: WhatsNew.Text(String(localized: localizedSubtitle))
        )
    }
}
