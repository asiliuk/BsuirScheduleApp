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
                observe: {
                    (
                        title: $0.title,
                        subtitle: $0.subtitle,
                        relativity: ScheduleDateTitle.Relativity($0.relativity)
                    )
                },
                removeDuplicates: ==
            ) { viewStore in
                ScheduleDateTitle(
                    date: viewStore.title,
                    relativeDate: viewStore.subtitle,
                    relativity: viewStore.relativity
                )
                .transaction { $0.animation = nil }
                .onAppear { viewStore.send(.onAppear) }
            }
        }
    }
}

private extension ScheduleDateTitle.Relativity {
    init(_ relativity: DaySectionFeature.State.Relativity) {
        switch relativity {
        case .past:
            self = .passed
        case .today:
            self = .today
        case .future:
            self = .upcoming
        }
    }
}
