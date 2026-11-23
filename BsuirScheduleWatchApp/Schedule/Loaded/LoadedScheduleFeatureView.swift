import SwiftUI
import ComposableArchitecture
import ScheduleCore
import BsuirCore
import BsuirUI

struct LoadedScheduleFeatureView: View {
    let store: StoreOf<LoadedScheduleFeature>
    let refresh: () async -> Void
    @State private var showOptions = false

    var body: some View {
        ZStack {
            switch store.viewOptions.displayType {
            case .continuous:
                ContinuousScheduleFeatureView(
                    store: store.scope(\.continuous, action: \.continuous)
                )
            case .compact:
                DayScheduleFeatureView(
                    store: store.scope(\.day, action: \.day)
                )
            case .exams:
                ExamsScheduleFeatureView(
                    store: store.scope(\.exams, action: \.exams)
                )
            }

        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(.screenScheduleViewTitle, systemImage: "line.3.horizontal.decrease") {
                    showOptions = true
                }
            }
        }
        .sheet(isPresented: $showOptions) {
            ScheduleViewOptionsFeatureView(
                store: store.scope(\.viewOptions, action: \.viewOptions)
            )
        }
        .refreshable { await refresh() }
        .onAppear { store.send(.onAppear) }
    }
}
