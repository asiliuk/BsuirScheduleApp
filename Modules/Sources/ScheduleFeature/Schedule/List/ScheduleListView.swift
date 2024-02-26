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
                ScheduleEmptyView()
            }
        }
    }
}

private struct ScheduleContentListView: View {
    @Perception.Bindable var store: StoreOf<ScheduleListFeature>
    @State var presentsPairDetailsPopover: Bool = false

    var body: some View {
        WithPerceptionTracking {
            ScrollableToTopList(isOnTop: $store.isOnTop.sending(\.setIsOnTop)) {
                Group {
                    WithPerceptionTracking {
                        if let header = store.header {
                            Text(header)
                                .foregroundStyle(.secondary)
                        }
                    }

                    ForEach(
                        store.scope(
                            state: \.days,
                            action: \.days
                        ),
                        content: DaySectionView.init
                    )

                    WithPerceptionTracking {
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
                }
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .onPreferenceChange(PresentsPairDetailsPopoverPreferenceKey.self) { presentsPairDetailsPopover = $0 }
            .environment(\.presentsPairDetailsPopover, presentsPairDetailsPopover)
        }
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
