import SwiftUI
import ComposableArchitecture
import BsuirUI

struct ContinuousScheduleFeatureView: View {
    let store: StoreOf<ContinuousScheduleFeature>

    var body: some View {
        if store.days.isEmpty {
            ScheduleEmptyView()
        } else {
            List {
                ForEach(store.scope(\.days, action: \.days)) { store in
                    DaySectionFeatureView(
                        store: store,
                        showPairWeeks: false
                    )
                }

                LoadMoreView(store: store)
            }
            .task {
                await store.send(.task).finish()
            }
        }
    }
}

struct LoadMoreView: View {
    let store: StoreOf<ContinuousScheduleFeature>

    var body: some View {
        Group {
            if store.loadMore {
                ProgressView()
                    .id(store.days.count)
                    .task {
                        try? await Task.sleep(for: .milliseconds(300))
                        store.send(.loadMore)
                    }
            } else if !store.days.isEmpty {
                Text(.screenScheduleContinuousFinished)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .listRowBackground(EmptyView())
    }
}
