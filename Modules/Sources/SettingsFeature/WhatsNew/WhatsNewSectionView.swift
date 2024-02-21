import SwiftUI
import ComposableArchitecture
import WhatsNewKit

struct WhatsNewSectionView: View {
    @Perception.Bindable var store: StoreOf<WhatsNewFeature>

    var body: some View {
        WithPerceptionTracking {
            Section {
                Button {
                    store.send(.whatsNewTapped)
                } label: {
                    Label("screen.settings.whatsNew.navigation.title", systemImage: "sparkles")
                        .settingsRowAccent(Color.red)
                        .badge(store.whatsNew.version.description)
                }
                .foregroundColor(.primary)

            }
            .sheet(
                item: $store.presentedWhatsNew,
                onDismiss: { store.send(.whatsNewDismissed) }
            ) { whatsNew in
                WhatsNewView(whatsNew: whatsNew)
            }
        }
    }
}
