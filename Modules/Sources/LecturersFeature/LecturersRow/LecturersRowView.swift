import SwiftUI
import BsuirUI
import ScheduleFeature
import ComposableArchitecture

struct LecturersRowView: View {
    let store: StoreOf<LecturersRow>

    struct ViewState: Equatable {
        let fullName: String
        let imageUrl: URL?
    }

    var body: some View {
        WithViewStore(
            store,
            observe: { ViewState(fullName: $0.fullName, imageUrl: $0.imageUrl) }
        ) { viewStore in
            NavigationLinkButton {
                viewStore.send(.rowTapped)
            } label: {
                LecturerCellView(
                    fullName: viewStore.fullName,
                    imageUrl: viewStore.imageUrl
                )
            }
            .markedScheduleRowActions(
                store: store.scope(
                    state: \.mark,
                    action: LecturersRow.Action.mark
                )
            )
        }
    }
}
