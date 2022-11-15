import SwiftUI
import LoadableFeature
import ComposableArchitecture
import ComposableArchitectureUtils

public struct ScheduleFeatureView<Value: Equatable>: View {
    public let store: StoreOf<ScheduleFeature<Value>>

    public init(store: StoreOf<ScheduleFeature<Value>>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: \.title) { viewStore in
            LoadingStore(
                store,
                state: \.$schedule,
                action: { .reducer(.daySchedule($0)) }
            ) { store in
                DayScheduleView(store: store.loaded(state: \.compact))
            } loading: {
                LoadingStateView()
            } error: { store in
                WithViewStore(store) { viewStore in
                    ErrorStateView(retry: { viewStore.send(.reload) })
                }
            }
            .navigationTitle(viewStore.state)
            .task { await viewStore.send(.task).finish() }
        }
    }
}
