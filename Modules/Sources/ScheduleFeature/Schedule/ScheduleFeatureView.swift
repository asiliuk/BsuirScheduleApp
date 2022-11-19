import SwiftUI
import LoadableFeature
import ComposableArchitecture
import ComposableArchitectureUtils

public struct ScheduleFeatureView<Value: Equatable>: View {
    struct ViewState: Equatable {
        let title: String
        let isFavorite: Bool
        let scheduleType: ScheduleDisplayType

        init(state: ScheduleFeature<Value>.State) {
            self.title = state.title
            self.isFavorite = state.isFavorite
            self.scheduleType = state.scheduleType
        }
    }

    public let store: StoreOf<ScheduleFeature<Value>>
    public let continiousSchedulePairDetails: ScheduleGridViewPairDetails
    
    public init(store: StoreOf<ScheduleFeature<Value>>, continiousSchedulePairDetails: ScheduleGridViewPairDetails) {
        self.store = store
        self.continiousSchedulePairDetails = continiousSchedulePairDetails
    }

    public var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            LoadingStore(
                store,
                state: \.$schedule,
                action: { .reducer(.schedule($0)) }
            ) { store in
                switch viewStore.scheduleType {
                case .compact:
                    DayScheduleView(
                        store: store
                            .loaded()
                            .scope(state: \.compact, action: { .day($0) })
                    )
                case .continuous:
                    ContiniousScheduleView(
                        store: store
                            .loaded()
                            .scope(state: \.continious, action: { .continious($0) }),
                        pairDetails: continiousSchedulePairDetails
                    )
                case .exams:
                    ExamsScheduleView(
                        store: store
                            .loaded()
                            .scope(state: \.exams, action: { .exams($0) })
                    )
                }
            } loading: {
                LoadingStateView()
            } error: { store in
                WithViewStore(store) { viewStore in
                    ErrorStateView(retry: { viewStore.send(.reload) })
                }
            }
            .toolbar {
                ToolbarItem {
                    HStack {
                        ToggleFavoritesButton(
                            isFavorite: viewStore.isFavorite,
                            toggle: { viewStore.send(.toggleFavoritesTapped) }
                        )
                        ScheduleDisplayTypePickerMenu(
                            scheduleType: viewStore.binding(
                                get: \.scheduleType,
                                send: { .view(.setScheduleType($0)) }
                            )
                        )
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text(viewStore.title)
                        .bold()
                        .minimumScaleFactor(0.5)
                        .onTapGesture { viewStore.send(.scrollToMostRelevantTapped) }
                }
            }
            .navigationTitle(viewStore.title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct ToggleFavoritesButton: View {
    let isFavorite: Bool
    let toggle: () -> Void

    var body: some View {
        Button(action: toggle) {
            Image(systemName: isFavorite ? "star.fill" : "star")
        }
        .accessibility(
            label: isFavorite
                ? Text("screen.schedule.favorite.accessibility.remove")
                : Text("screen.schedule.favorite.accessibility.add")
        )
        .accentColor(.yellow)
    }
}
