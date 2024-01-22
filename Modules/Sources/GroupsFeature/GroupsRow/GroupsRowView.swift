import SwiftUI
import BsuirUI
import ScheduleFeature
import ComposableArchitecture

struct GroupsRowView: View {
    let store: StoreOf<GroupsRow>

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
                    action: \.mark
                )
            )
        }
    }
}
