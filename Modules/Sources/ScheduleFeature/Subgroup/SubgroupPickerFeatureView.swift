import SwiftUI
import ComposableArchitecture

struct SubgroupPickerFeatureMenuView: View {
    @Bindable var store: StoreOf<SubgroupPickerFeature>
    @State var selectedSubgroup: Int?

    var body: some View {
        Menu {
            SubgroupPickerView(
                maxSubgroup: store.maxSubgroup,
                selection: $selectedSubgroup
            )
        } label: {
            if let selected = store.selected {
                Label.compactSubgroup(selected)
            } else {
                Label.allSubgroups
            }
        }
        .tint(store.selected == nil ? .secondary : .blue)
        .bind($store.selected, to: $selectedSubgroup)
    }
}

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
        Picker("view.subgroupPicker.title", selection: $selection) {
            ForEach(1...maxSubgroup, id: \.self) { subgroup in
                Label.subgroup(subgroup)
                    .tag(Int?.some(subgroup))
                    .labelStyle(.titleAndIcon)
            }

            Label.allSubgroups.tag(Int?.none)
        }
    }
}

private extension Label<Text, Image> {
    static let allSubgroups = Label("view.subgroupPicker.allSubgroups.title", systemImage: "person.2")

    static func subgroup(_ subgroup: Int) -> Label {
        Label("view.subgroupPicker.subgroup.title\(String(describing: subgroup))", systemImage: "person")
    }

    static func compactSubgroup(_ subgroup: Int) -> Label {
        Label("view.subgroupPicker.subgroup.title\(String(describing: subgroup))", image: "subgroup.\(subgroup).circle")
    }
}
