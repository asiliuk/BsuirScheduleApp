import SwiftUI
import ComposableArchitecture

struct GroupSectionView: View {
    let store: StoreOf<GroupSection>
    init(store: StoreOf<GroupSection>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store, observe: \.title) { viewStore in
            Section(viewStore.state) {
                ForEachStore(
                    store.scope(
                        state: \.groupRows,
                        action: GroupSection.Action.groupRow
                    )
                ) { store in
                    GroupRowView(store: store)
                }
            }
        }
    }
}
