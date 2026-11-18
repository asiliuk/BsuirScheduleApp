import SwiftUI
import BsuirUI
import ComposableArchitecture

struct ScheduleListView: View {
    let store: StoreOf<ScheduleListFeature>

    var body: some View {
        if store.hasSchedule {
            if #available(iOS 26, *) {
                ScheduleContentGridView(store: store)
            } else {
                ScheduleContentListView(store: store)
            }
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

@available(iOS 26, *)
private struct ScheduleContentGridView: View {
    @Bindable var store: StoreOf<ScheduleListFeature>

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [.init(.adaptive(minimum: 300, maximum: 600), spacing: 16, alignment: .top)], spacing: 32, pinnedViews: .sectionHeaders) {
                Section {
                    ForEach(store.scope(state: \.days, action: \.days)) { store in
                        VStack(alignment: .leading) {
                            DaySectionHeaderView(store: store)
                            DaySectionPairsView(store: store)
                        }
                    }
                } footer: {
                    if case .finished = store.loading {
                        NoMorePairsIndicator()
                    }
                }

                if case .loadMore = store.loading {
                    ShimmeringPairPlaceholder()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .onAppear { store.send(.loadingIndicatorAppeared) }
                }
            }
            .padding()
        }
        .navigationSubtitle(store.fullSubtitle)
    }
}

private extension ScheduleListFeature.State {
    var fullSubtitle: Text {
        switch (title, subtitle) {
        case let (lhs?, rhs?): return Text("\(lhs) · \(rhs)")
        case let (nil, rhs?): return Text(rhs)
        case let (lhs?, nil): return Text(lhs)
        case (nil, nil): return Text("")
        }
    }
}

private struct ScheduleContentListView: View {
    @Bindable var store: StoreOf<ScheduleListFeature>

    var body: some View {
        List {
            Group {
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

                ForEach(store.scope(state: \.days, action: \.days)) { store in
                    Section {
                        DaySectionPairsView(store: store)
                    } header:{
                        DaySectionHeaderView(store: store)
                    }
                }

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
