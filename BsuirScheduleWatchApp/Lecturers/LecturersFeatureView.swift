import SwiftUI
import ComposableArchitecture
import LoadableFeature
import BsuirApi

struct LecturersFeatureView: View {
    @Bindable var store: StoreOf<LecturersFeature>

    var body: some View {
        NavigationStack(path: $store.scope(\.path, action: \.path)) {
            LoadingView(store: store.scope(\.lecturers, action: \.lecturers)) {
                ProgressView()
            } failed: { store, _ in
                LoadingErrorView(store: store)
            } loaded: { store, refresh in
                LoadedLecturersFeatureView(store: store, refresh: refresh)
            }
        } destination: { store in
            ScheduleFeatureView(store: store)
        }
    }
}

