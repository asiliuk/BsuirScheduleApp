import SwiftUI
import BsuirUI
import ComposableArchitecture

struct DaySectionView: View {
    let store: StoreOf<DaySectionFeature>
    @State var title: String = ""
    @State var subtitle: String? = nil
    @State var relativity: ScheduleDateTitle.Relativity = .upcoming

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
                .transformEnvironment(\.pairFilteringMode) { mode in
                    // Filter all pairs in passed section
                    if relativity == .passed { mode = .filter }
                }
            } header:{
                ScheduleDateTitle(
                    date: title,
                    relativeDate: subtitle,
                    relativity: relativity
                )
                .transaction { $0.animation = nil }
                .onAppear {
                    // This data is dynamic and depends on `.now` value
                    // We should recalculate it every time view appears
                    // It is intentionally moved to view layer to prevent
                    // spamming store with `onAppear` events too often
                    title = store.dayDate.title
                    subtitle = store.dayDate.subtitle(for: .now)
                    relativity = ScheduleDateTitle.Relativity(store.dayDate.relativity(for: .now))
                }
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
