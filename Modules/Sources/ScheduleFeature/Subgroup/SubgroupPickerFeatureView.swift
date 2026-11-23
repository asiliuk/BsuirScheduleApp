import SwiftUI
import ComposableArchitecture
import BsuirUI

struct SubgroupPickerFeatureView: View {
    @Bindable var store: StoreOf<SubgroupPickerFeature>

    var body: some View {
        SubgroupPickerView(maxSubgroup: store.maxSubgroup, selection: $store.selected)
    }
}

private struct SubgroupPickerView: View {
    let maxSubgroup: Int
    @Binding var selection: Int?

    var body: some View {
        Picker(.subgroupPickerTitle, selection: $selection) {
            ForEach(1...maxSubgroup, id: \.self) { subgroup in
                Label.subgroup(subgroup)
                    .tag(Int?.some(subgroup))
                    .labelStyle(.titleAndIcon)
            }

            Label.allSubgroups.tag(Int?.none)
        }
    }
}
