import SwiftUI
import ComposableArchitecture
import WhatsNewKit

struct WhatsNewFeatureView: View {
    var store: StoreOf<WhatsNewFeature>

    var body: some View {
        WhatsNewView(whatsNew: store.whatsNew)
    }
}
