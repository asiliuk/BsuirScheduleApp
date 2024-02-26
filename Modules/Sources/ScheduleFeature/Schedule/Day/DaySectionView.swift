import SwiftUI
import BsuirUI
import ComposableArchitecture

struct DaySectionView: View {
    let store: StoreOf<DaySectionFeature>

    var body: some View {
        WithPerceptionTracking {
            Section {
                ForEach(
                    store.scope(
                        state: \.pairRows,
                        action: \.pairRows
                    ),
                    content: { PairRowView(store: $0) }
                )
            } header:{
                ScheduleDateTitle(
                    date: store.title,
                    relativeDate: store.subtitle,
                    relativity: ScheduleDateTitle.Relativity(store.relativity)
                )
                .transaction { $0.animation = nil }
                .onAppear { store.send(.onAppear) }
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
