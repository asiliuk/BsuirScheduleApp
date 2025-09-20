import SwiftUI
import BsuirCore
import BsuirUI
import LoadableFeature
import ComposableArchitecture

public struct ScheduleFeatureView<Value: Equatable>: View {
    public let store: StoreOf<ScheduleFeature<Value>>

    public init(store: StoreOf<ScheduleFeature<Value>>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
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
            .toolbar {
                if let store = store.scope(state: \.mark, action: \.mark) {
                    if #available(iOS 26, *) {
                        ToolbarSpacer(.fixed, placement: .primaryAction)
                    }
                    ToolbarItemGroup(placement: .primaryAction) {
                        MarkedSchedulePickerView(store: store)
                    }
                }
            }
            .navigationTitle(store.title)
        }
    }
}

private struct LoadedScheduleView: View {
    @Perception.Bindable var store: StoreOf<LoadedScheduleReducer>

    var body: some View {
        WithPerceptionTracking {
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
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    ScheduleDisplayTypePickerMenu(
                        scheduleType: $store.scheduleType
                    )
                }

                if let store = store.scope(state: \.subgroupPicker, action: \.subgroupPicker) {
                    ToolbarItem(placement: .topBarTrailing) {
                        SubgroupPickerFeatureView(store: store)
                    }
                }
            }
        }
    }
}
