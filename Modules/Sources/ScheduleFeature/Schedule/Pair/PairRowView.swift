import SwiftUI
import ComposableArchitecture
import BsuirUI

struct PairRowView: View {
    let store: StoreOf<PairRowFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            PairCell(
                pair: viewStore.pair,
                showWeeks: viewStore.showWeeks,
                details: detailsView(viewStore: viewStore)
            )
        }
    }

    @ViewBuilder
    private func detailsView(viewStore: ViewStoreOf<PairRowFeature>) -> some View {
        switch viewStore.details {
        case .lecturers:
            LecturerAvatarsDetails(lecturers: viewStore.pair.lecturers) {
                viewStore.send(.lecturerTapped($0))
            }
        case .groups:
            GroupPairDetails(groups: viewStore.pair.groups) {
                viewStore.send(.groupTapped($0))
            }
        case nil:
            EmptyView()
        }
    }
}
