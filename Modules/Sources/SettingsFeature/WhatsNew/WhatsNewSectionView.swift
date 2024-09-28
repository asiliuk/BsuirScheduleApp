import SwiftUI
import ComposableArchitecture
import WhatsNewKit

struct WhatsNewFeatureView: View {
    var store: StoreOf<WhatsNewFeature>

    var body: some View {
        WithPerceptionTracking {
            WhatsNewView(whatsNew: store.whatsNew)
        }
    }
}
