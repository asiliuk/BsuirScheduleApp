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
                Text(verbatim: "Continuous")
            case .compact:
                DayScheduleFeatureView(
                    store: store.scope(\.day, action: \.day)
                )
            case .exams:
                Text(verbatim: "Exams")
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
    }
}
