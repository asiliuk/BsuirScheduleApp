import SwiftUI
import BsuirUI
import ScheduleFeature
import ComposableArchitecture

struct GroupRowView: View {
    let store: StoreOf<GroupRow>

    var body: some View {
        WithViewStore(store, observe: \.title) { viewStore in
            NavigationLinkButton {
                viewStore.send(.rowTapped)
            } label: {
                Text(viewStore.state).monospacedDigit()
            }
            .markedScheduleRowActions(
                store: store.scope(
                    state: \.mark,
                    action: GroupRow.Action.mark
                )
            )
        }
    }
}
