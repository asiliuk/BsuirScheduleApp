import SwiftUI
import ComposableArchitecture

struct SubgroupPickerFeatureView: View {
    @Perception.Bindable var store: StoreOf<SubgroupPickerFeature>

    var body: some View {
        WithPerceptionTracking {
            Menu {
                Picker("view.subgroupPicker.title", selection: $store.selected) {
                    ForEach(1...store.maxSubgroup, id: \.self) { subgroup in
                        Label("view.subgroupPicker.subgroup.title\(String(describing: subgroup))", systemImage: "person")
                            .tag(Int?.some(subgroup))
                            .labelStyle(.titleAndIcon)
                    }

                    Label("view.subgroupPicker.allSubgroups.title", systemImage: "person.2").tag(Int?.none)
                }
            } label: {
                if let selected = store.selected {
                    Text("\(Image(systemName: "person.fill"))\(selected)")
                        .monospacedDigit()
                } else {
                    Image(systemName: "person.2")
                }
            }
            .tint(store.selected == nil ? .secondary : .blue)
        }
    }
}
