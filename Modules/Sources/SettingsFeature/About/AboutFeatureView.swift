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
                    LinkButton(title: "Github") { viewStore.send(.githubButtonTapped) }
                    LinkButton(title: "Telegram") { viewStore.send(.telegramButtonTapped) }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("screen.settings.about.navigation.title")
        }
    }
}

private struct LinkButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) { Text(title).underline() }
    }
}
