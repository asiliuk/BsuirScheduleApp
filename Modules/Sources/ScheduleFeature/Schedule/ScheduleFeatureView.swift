import SwiftUI
import BsuirCore
import BsuirUI
import LoadableFeature
import ComposableArchitecture

public struct ScheduleFeatureView<Value: Equatable>: View {
    public var store: StoreOf<ScheduleFeature<Value>>

    public init(store: StoreOf<ScheduleFeature<Value>>) {
        self.store = store
    }

    public var body: some View {
        LoadingView(
            store: store.scope(state: \.schedule, action: \.schedule),
            inProgress: {
                ShimmeringSchedulePlaceholder()
            },
            failed: { store, _ in
                LoadingErrorView(store: store)
            },
            loaded: { store, refresh in
                LoadedScheduleView(
                    store: store
                )
                .refreshable { await refresh() }
            }
        )
        .markedScheduleToolbar(store: store.scope(\.mark, action: \.mark))
        .navigationTitle(store.title)
    }
}

private struct LoadedScheduleView: View {
    @Bindable var store: StoreOf<LoadedScheduleReducer>

    var body: some View {
        ZStack {
            switch store.scheduleType {
            case .continuous:
                ContinuousScheduleView(
                    store: store.scope(state: \.continuous, action: \.continuous)
                )
            case .compact:
                DayScheduleView(
                    store: store.scope(state: \.compact, action: \.day)
                )
            case .exams:
                ExamsScheduleView(
                    store: store.scope(state: \.exams, action: \.exams)
                )
            }
        }
        .environment(
            \.pairFilteringMode,
             store.subgroupPicker.pairFilteringMode
        )
        .onAppear { store.send(.onAppear) }
        .toolbar {
            Menu("screen.schedule.view.title", systemImage: "line.3.horizontal.decrease.circle") {
                Section {
                    ScheduleDisplayTypePicker(scheduleType: $store.scheduleType)
                        .tint(nil)
                }

                if let store = store.scope(state: \.subgroupPicker, action: \.subgroupPicker) {
                    Section {
                        SubgroupPickerFeatureView(store: store)
                            .tint(nil)
                    }
                }
            }
        }
        .navigationTitle(store.navigationTitle)
        .bsuirNavigationSubtitle(store.navigationSubtitle)
    }
}

private extension SubgroupPickerFeature.State? {
    var pairFilteringMode: PairFilteringMode {
        guard let selected = self?.selected else { return .noFiltering }
        return .keepingSubgroup(selected)
    }
}

private extension LoadedScheduleReducer.State {
    var scheduleTypeName: Text? {
        switch scheduleType {
        case .continuous: nil
        case .compact: Text("screen.schedule.scheduleType.byDay")
        case .exams: Text("screen.schedule.scheduleType.exams")
        }
    }

    var scheduleDuration: Text? {
        let startDate: Date?
        let endDate: Date?

        switch scheduleType {
        case .continuous, .compact:
            startDate = response.startDate
            endDate = response.endDate
        case .exams:
            startDate = response.startExamsDate
            endDate = response.endExamsDate
        }

        guard let startDate, let endDate else { return nil }
        return Text((startDate..<endDate).formatted(.scheduleDates))
    }

    var navigationSubtitle: Text? {
        combineTexts(
            scheduleTypeName,
            scheduleDuration,
            separator: " • "
        )
    }

    var navigationTitle: String {
        guard let selected = subgroupPicker?.selected else { return source.title }
        return "\(source.title)/\(selected)"
    }
}
