import SwiftUI
import BsuirUI
import ScheduleFeature
import ComposableArchitecture

struct GroupsRowView: View {
    let store: StoreOf<GroupsRow>

    var body: some View {
        WithPerceptionTracking {
            NavigationLinkButton {
                store.send(.rowTapped)
            } label: {
                Text(store.title).monospacedDigit()
            }
            .markedScheduleRowActions(store: store.scope(state: \.mark, action: \.mark))
        }
    }
}
