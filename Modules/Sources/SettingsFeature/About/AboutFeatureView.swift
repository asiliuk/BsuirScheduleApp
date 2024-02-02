import SwiftUI
import ComposableArchitecture

struct AboutFeatureView: View {
    let store: StoreOf<AboutFeature>

    var body: some View {
        List {
            Section("screen.settings.about.version.section.header") {
                WithPerceptionTracking {
                    Text(store.appVersion)
                }
            }

            Section("screen.settings.about.links.section.header") {
                Button {
                    store.send(.githubButtonTapped)
                } label: {
                    Label("Github", systemImage: "curlybraces")
                }

                Button {
                    store.send(.telegramButtonTapped)
                } label: {
                    Label("Telegram", systemImage: "paperplane")
                }

                Button {
                    store.send(.reviewButtonTapped)
                } label: {
                    Label("screen.settings.about.links.rate.title", systemImage: "star")
                }
            }

            Section("screen.settings.docs.links.section.header") {
                Button {
                    store.send(.privacyPolicyTapped)
                } label: {
                    Label("screen.settings.docs.links.privacy.title", systemImage: "person.badge.shield.checkmark")
                }

                Button {
                    store.send(.termsAndConditionsTapped)
                } label: {
                    Label("screen.settings.docs.links.terms.title", systemImage: "doc.plaintext")
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("screen.settings.about.navigation.title")
    }
}
