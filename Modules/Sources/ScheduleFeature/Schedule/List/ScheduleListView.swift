import SwiftUI
import BsuirUI
import ComposableArchitecture

struct ScheduleListView: View {
    let store: StoreOf<ScheduleListFeature>

    var body: some View {
        WithPerceptionTracking {
            if store.hasSchedule {
                ScheduleContentListView(store: store)
            } else {
                switch store.scheduleType {
                case .continuous, .compact:
                    ScheduleEmptyView()
                case .exams:
                    ExamsEmptyView { store.send(.checkScheduleTapped) }
                }
            }
        }
    }
}

private struct ScheduleContentListView: View {
    @Perception.Bindable var store: StoreOf<ScheduleListFeature>
    @State var presentsPairDetailsPopover: Bool = false

    var body: some View {
        List {
            WithPerceptionTracking {
                if store.title != nil || store.subtitle != nil {
                    VStack(alignment: .leading) {
                        if let title = store.title {
                            Text(title)
                                .font(.headline)
                                .foregroundStyle(.primary)
                        }

                        if let subtitle = store.subtitle {
                            Text(subtitle)
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                ForEach(
                    store.scope(
                        state: \.days,
                        action: \.days
                    ),
                    content: DaySectionView.init
                )

                switch store.loading {
                case .loadMore:
                    ShimmeringPairPlaceholder()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .onAppear { store.send(.loadingIndicatorAppeared) }
                case .finished:
                    NoMorePairsIndicator()
                case .never:
                    EmptyView()
                }
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .onPreferenceChange(PresentsPairDetailsPopoverPreferenceKey.self) { presentsPairDetailsPopover = $0 }
        .environment(\.presentsPairDetailsPopover, presentsPairDetailsPopover)
    }
}

struct NoMorePairsIndicator: View {
    var body: some View {
        Text("screen.schedule.noMorePairs.title")
            .font(.headline)
            .frame(minWidth: 0, maxWidth: .infinity)
            .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}
