import SwiftUI
import ComposableArchitecture

struct AboutFeatureView: View {
    let store: StoreOf<AboutFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List {
                Section("screen.settings.about.version.section.header") {
                    Text(viewStore.appVersion)
                }

                Section("screen.settings.about.links.section.header") {
                    Button {
                        viewStore.send(.githubButtonTapped)
                    } label: {
                        Label("Github", systemImage: "curlybraces")
                    }

                    Button {
                        viewStore.send(.telegramButtonTapped)
                    } label: {
                        Label("Telegram", systemImage: "paperplane")
                    }

                    Button {
                        viewStore.send(.reviewButtonTapped)
                    } label: {
                        Label("screen.settings.about.links.rate.title", systemImage: "star")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("screen.settings.about.navigation.title")
        }
    }
}
