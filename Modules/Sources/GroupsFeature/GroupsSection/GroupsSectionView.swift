import SwiftUI
import ComposableArchitecture

struct GroupsSectionView: View {
    let store: StoreOf<GroupsSection>
    init(store: StoreOf<GroupsSection>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store, observe: \.title) { viewStore in
            Section(viewStore.state) {
                ForEachStore(
                    store.scope(
                        state: \.groupRows,
                        action: GroupsSection.Action.groupRows
                    )
                ) { store in
                    GroupsRowView(store: store)
                }
            }
        }
    }
}
