import SwiftUI
import BsuirCore
import BsuirUI
import LoadableFeature
import ComposableArchitecture

public struct ScheduleFeatureView<Value: Equatable>: View {
    @Perception.Bindable public var store: StoreOf<ScheduleFeature<Value>>

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
                        store: store,
                        scheduleType: self.store.scheduleType
                    )
                    .refreshable { await refresh() }
                }
            )
            .toolbar {
                ToolbarItem(placement: .principal) {
                    ScheduleDisplayTypePicker(
                        scheduleType: $store.scheduleType.animation(.default)
                    )
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                }

                if let store = store.scope(state: \.subgroupPicker, action: \.subgroupPicker) {
                    ToolbarItemGroup(placement: .primaryAction) {
                        SubgroupPickerFeatureView(store: store)
                    }
                }

                if let store = store.scope(state: \.mark, action: \.mark) {
                    ToolbarItemGroup(placement: .primaryAction) {
                        MarkedSchedulePickerView(store: store)
                    }
                }
            }
            .navigationTitle(store.title)
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

private struct LoadedScheduleView: View {
    let store: StoreOf<LoadedScheduleReducer>
    let scheduleType: ScheduleDisplayType

    var body: some View {
        switch scheduleType {
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
}
