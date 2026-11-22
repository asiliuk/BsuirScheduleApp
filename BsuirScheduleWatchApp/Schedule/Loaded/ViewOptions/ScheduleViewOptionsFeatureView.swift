import SwiftUI
import ComposableArchitecture
import ScheduleCore
import BsuirUI

struct ScheduleViewOptionsFeatureView: View {
    @Bindable var store: StoreOf<ScheduleViewOptionsFeature>

    var body: some View {
        NavigationStack {
            List {
                Picker(ScheduleDisplayType.pickerTitle, selection: $store.displayType) {
                    ForEach(ScheduleDisplayType.allCases, id: \.self) { scheduleType in
                        Label(scheduleType.title, systemImage: scheduleType.imageName)
                    }
                }
                .pickerStyle(.inline)
            }
            .navigationTitle(.screenScheduleViewTitle)
        }
    }
}
