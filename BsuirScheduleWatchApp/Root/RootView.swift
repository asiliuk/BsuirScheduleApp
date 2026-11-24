import SwiftUI
import ComposableArchitecture

struct RootView: View {
    let store: StoreOf<RootFeature>

    var body: some View {
        TabView {
            Tab {
                PinnedFeatureView(
                    store: store.scope(\.pinned, action: \.pinned)
                )
            }

            Tab {
                GroupsFeatureView(
                    store: store.scope(\.groups, action: \.groups)
                )
            }

            Tab {
                LecturersFeatureView(
                    store: store.scope(\.lecturers, action: \.lecturers)
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
