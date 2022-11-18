import SwiftUI
import LoadableFeature
import ComposableArchitecture
import ComposableArchitectureUtils

public struct ScheduleFeatureView<Value: Equatable>: View {
    public let store: StoreOf<ScheduleFeature<Value>>
    public let continiousSchedulePairDetails: ScheduleGridViewPairDetails
    
    public init(store: StoreOf<ScheduleFeature<Value>>, continiousSchedulePairDetails: ScheduleGridViewPairDetails) {
        self.store = store
        self.continiousSchedulePairDetails = continiousSchedulePairDetails
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
            .navigationTitle(viewStore.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    HStack {
                        ScheduleDisplayTypePickerMenu(
                            scheduleType: viewStore.binding(\.$scheduleType)
                        )
                        ToggleFavoritesButton(
                            isFavorite: viewStore.isFavorite,
                            toggle: { viewStore.send(.toggleFavoritesTapped) }
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
