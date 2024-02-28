import SwiftUI
import BsuirUI
import ScheduleFeature
import ComposableArchitecture

struct GroupsRowViewV2: View {
    let store: StoreOf<GroupsRowV2>

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
