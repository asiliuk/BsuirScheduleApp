import SwiftUI
import BsuirCore
import BsuirUI
import LoadableFeature
import ComposableArchitecture

public struct ScheduleFeatureView<Value: Equatable>: View {
    struct ViewState: Equatable {
        let title: String
        let scheduleType: ScheduleDisplayType

        init(state: ScheduleFeature<Value>.State) {
            self.title = state.title
            self.scheduleType = state.scheduleType
        }
    }

    public let store: StoreOf<ScheduleFeature<Value>>
    
    public init(store: StoreOf<ScheduleFeature<Value>>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            LoadingStore(
                store,
                state: \.$schedule,
                action: { .schedule($0) }
            ) { store in
                LoadedScheduleView(
                    store: store.loaded(),
                    scheduleType: viewStore.scheduleType
                )
                .refreshable { await store.send(.refresh).finish() }
            } loading: {
                ScheduleGridPlaceholder()
            } error: { store in
                LoadingErrorView(store: store)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    ScheduleDisplayTypePicker(
                        scheduleType: viewStore
                            .binding(get: \.scheduleType, send: { .setScheduleType($0) })
                            .animation(.default)
                    )
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                }

                ToolbarItem {
                    MarkedSchedulePickerView(
                        store: store.scope(
                            state: \.mark,
                            action: { .mark($0) }
                        )
                    )
                }
            }
            .navigationTitle(viewStore.title)
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
                store: store.scope(state: \.continuous, action: { .continuous($0) })
            )
        case .compact:
            DayScheduleView(
                store: store.scope(state: \.compact, action: { .day($0) })
            )
        case .exams:
            ExamsScheduleView(
                store: store.scope(state: \.exams, action: { .exams($0) })
            )
        }
    }
}
