import SwiftUI
import ComposableArchitecture

struct PairFormIconsView: View {
    let store: StoreOf<PairFormIcons>

    var body: some View {
        // TODO: add a footer explaining where this could be seen
        Section(header: Text("screen.settings.appearance.icons.section.header")) {
            ForEachStore(
                store.scope(
                    state: \.pairFormIcons,
                    action: { .pairFormIcon(id: $0, action: $1) }
                ),
                content: PairFormIconView.init(store:)
            )
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
