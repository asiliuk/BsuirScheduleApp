import Foundation
import SwiftUI
import WhatsNewKit

extension WhatsNew.Feature {
    init(
        image: Image,
        localizedTitle: LocalizedStringResource,
        localizedSubtitle: LocalizedStringResource
    ) {
        self.init(
            image: image,
            title: WhatsNew.Text(AttributedString(localized: localizedTitle)),
            subtitle: WhatsNew.Text(AttributedString(localized: localizedSubtitle))
        )
    }
}

extension WhatsNew.PrimaryAction {
    public init(
        localizedTitle: LocalizedStringResource,
        backgroundColor: Color = .accentColor,
        foregroundColor: Color = .white,
        hapticFeedback: WhatsNew.HapticFeedback? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.init(
            title: WhatsNew.Text(AttributedString(localized: localizedTitle)),
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            hapticFeedback: hapticFeedback,
            onDismiss: onDismiss
        )
    }
}
