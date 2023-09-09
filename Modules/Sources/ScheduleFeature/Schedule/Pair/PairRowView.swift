import SwiftUI
import ComposableArchitecture
import BsuirUI
import ScheduleCore

struct PairRowView: View {
    struct ViewState: Equatable {
        let pair: PairViewModel
        let showWeeks: Bool
        let details: PairRowDetails?

        init(_ state: PairRowFeature.State) {
            self.pair = state.pair
            self.showWeeks = state.showWeeks
            self.details = state.details
        }
    }

    let store: StoreOf<PairRowFeature>

    var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            Button {
                viewStore.send(.rowTapped)
            } label: {
                PairCell(
                    pair: viewStore.pair,
                    showWeeks: viewStore.showWeeks,
                    details: detailsView(pair: viewStore.pair, details: viewStore.details)
                )
            }
            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
            .buttonStyle(.plain)
            .popover(
                store: store.scope(state: \.$pairDetails, action: { .pairDetails($0) }), 
                content: PairDetailsView.init
            )
        }
    }

    @ViewBuilder
    private func detailsView(pair: PairViewModel, details: PairRowDetails?) -> some View {
        switch details {
        case .lecturers:
            LecturerAvatarsDetails(lecturers: pair.lecturers)
        case .groups:
            GroupPairDetails(groups: pair.groups)
        case nil:
            EmptyView()
        }
    }
}
