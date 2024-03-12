import SwiftUI
import BsuirUI
import ComposableArchitecture

struct LoadedLecturersFeatureView: View {
    @Perception.Bindable var store: StoreOf<LoadedLecturersFeature>
    let refresh: () async -> Void
    
    var body: some View {
        WithPerceptionTracking {
            List {
                if !store.pinnedRows.isEmpty  {
                    Section("screen.lecturers.pinned.section.header") {
                        ForEach(store.scope(state: \.pinnedRows, action: \.lecturerRows)) { store in
                            LecturersRowView(store: store)
                        }
                    }
                }

                if !store.favoriteRows.isEmpty {
                    Section("screen.lecturers.favorites.section.header") {
                        ForEach(store.scope(state: \.favoriteRows, action: \.lecturerRows)) { store in
                            LecturersRowView(store: store)
                        }
                    }
                }

                Section {
                    ForEach(store.scope(state: \.visibleRows, action: \.lecturerRows)) { store in
                        LecturersRowView(store: store)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .refreshable { await refresh() }
            .overlay {
                if #available(iOS 17, *) {
                    if store.isEmpty {
                        ContentUnavailableView.search
                    }
                }
            }
            .dismissSearch(store.searchDismiss)
            .searchable(text: $store.searchQuery, prompt: "screen.lecturers.search.placeholder")
            .task { await store.send(.task).finish() }
        }
    }
}
