import SwiftUI
import BsuirUI
import ScheduleFeature
import ComposableArchitecture

struct LecturersRowView: View {
    let store: StoreOf<LecturersRow>

    struct ViewState: Equatable {
        let fullName: String
        let imageUrl: URL?

        init(state: LecturersRow.State) {
            self.fullName = state.fullName
            self.imageUrl = state.imageUrl
        }
    }

    var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
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
                    action: \.mark
                )
            )
        }
    }
}
