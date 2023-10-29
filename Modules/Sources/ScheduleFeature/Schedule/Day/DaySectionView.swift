import SwiftUI
import BsuirUI
import ComposableArchitecture

struct DaySectionView: View {
    let store: StoreOf<DaySectionFeature>

    var body: some View {
        Section {
            ForEachStore(
                store.scope(
                    state: \.pairRows,
                    action: { .pairRow(id: $0, action: $1) }
                ),
                content: { PairRowView(store: $0) }
            )
        } header: {
            WithViewStore(
                store,
                observe: { (title: $0.title, subtitle: $0.subtitle, isToday: $0.isToday) },
                removeDuplicates: ==
            ) { viewStore in
                ScheduleDateTitle(
                    date: viewStore.title,
                    relativeDate: viewStore.subtitle,
                    isToday: viewStore.isToday
                )
                .transaction { $0.animation = nil }
                .onAppear { viewStore.send(.onAppear) }
            }
        }
    }
}
