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
        WithViewStore(store, observe: { $0 }) { viewStore in
            LoadingStore(
                store,
                state: \.$schedule,
                action: { .reducer(.schedule($0)) }
            ) { store in
                switch viewStore.scheduleType {
                case .compact:
                    DayScheduleView(store: store.loaded().scope(state: \.compact, action: { .day($0) }))
                case .continuous:
                    ContiniousScheduleView(store: store.loaded().scope(state: \.continious, action: { .continious($0) }))
                case .exams:
                    EmptyView()
                }
            } loading: {
                LoadingStateView()
            } error: { store in
                WithViewStore(store) { viewStore in
                    ErrorStateView(retry: { viewStore.send(.reload) })
                }
            }
            .navigationTitle(viewStore.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    ScheduleDisplayTypePickerMenu(
                        scheduleType: viewStore.binding(\.$scheduleType)
                    )
                }
                
                ToolbarItem(placement: .principal) {
                    Text(viewStore.title)
                        .bold()
                        .minimumScaleFactor(0.5)
                        .onTapGesture { viewStore.send(.scrollToMostRelevantTapped) }
                }
            }
            .task { await viewStore.send(.task).finish() }
        }
    }
}
