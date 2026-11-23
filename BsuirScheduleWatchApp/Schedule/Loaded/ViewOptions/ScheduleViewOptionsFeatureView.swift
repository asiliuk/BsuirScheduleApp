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

                if let store = store.scope(\.subgroup, action: \.subgroup) {
                    ScheduleSubgroupFeatureView(store: store)
                }
            }
            .pickerStyle(.inline)
            .navigationTitle(.screenScheduleViewTitle)
        }
    }
}

struct ScheduleSubgroupFeatureView: View {
    @Bindable var store: StoreOf<ScheduleSubgroupFeature>

    var body: some View {
        Picker(.subgroupPickerTitle, selection: $store.selected) {
            ForEach(1...store.max, id: \.self) { subgroup in
                Label.subgroup(subgroup)
                    .tag(Int?.some(subgroup))
                    .labelStyle(.titleAndIcon)
            }

            Label.allSubgroups.tag(Int?.none)
        }
    }
}
