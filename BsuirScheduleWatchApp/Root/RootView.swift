import SwiftUI
import ComposableArchitecture

struct RootView: View {
    let store: StoreOf<RootFeature>

    var body: some View {
        TabView {
            Tab {
                GroupsFeatureView(
                    store: store.scope(\.groups, action: \.groups)
                )
            }

            Tab {
                ContentView(
                    store: store.scope(\.content, action: \.content)
                )
            }
        }
    }
}
