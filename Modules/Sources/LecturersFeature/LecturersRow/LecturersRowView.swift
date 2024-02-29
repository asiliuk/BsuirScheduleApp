import SwiftUI
import BsuirUI
import ScheduleFeature
import ComposableArchitecture

struct LecturersRowView: View {
    let store: StoreOf<LecturersRow>

    var body: some View {
        WithPerceptionTracking {
            NavigationLinkButton {
                store.send(.rowTapped)
            } label: {
                LecturerCellView(
                    fullName: store.fullName,
                    imageUrl: store.imageUrl
                )
            }
            .markedScheduleRowActions(store: store.scope(state: \.mark, action: \.mark))
        }
    }
}
