import SwiftUI
import ComposableArchitecture
import WhatsNewKit

struct WhatsNewSectionView: View {
    let store: StoreOf<WhatsNewFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Section {
                Button {
                    viewStore.send(.whatsNewTapped)
                } label: {
                    Label("screen.settings.whatsNew.navigation.title", systemImage: "sparkles")
                        .settingsRowAccent(Color.red)
                        .badge(viewStore.whatsNew.version.description)
                }
                .foregroundColor(.primary)

            }
            .sheet(
                item: viewStore.binding(
                    get: \.presentedWhatsNew,
                    send: { .setPresentedWhatsNew($0) }
                ),
                onDismiss: {
                    viewStore.send(.whatsNewDismissed)
                }
            ) { whatsNew in
                WhatsNewView(whatsNew: whatsNew)
            }
        }
    }
}
