import SwiftUI
import ComposableArchitecture

struct PairFormIconsView: View {
    let store: StoreOf<PairFormIcons>

    var body: some View {
        Section {
            ForEachStore(
                store.scope(
                    state: \.pairFormIcons,
                    action: { .pairFormIcon(id: $0, action: $1) }
                ),
                content: PairFormIconView.init(store:)
            )
        } header: {
            Text("screen.settings.appearance.icons.section.header")
        } footer: {
            Text("screen.settings.appearance.icons.section.footer")
        }
    }
}

private struct PairFormIconView: View {
    let store: StoreOf<PairFormIcon>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            LabeledContent(viewStore.name) {
                Image(systemName: viewStore.icon).foregroundColor(.primary)
            }
        }
    }
}
