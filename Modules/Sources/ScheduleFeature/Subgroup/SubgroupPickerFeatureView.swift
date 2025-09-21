import SwiftUI
import ComposableArchitecture

struct SubgroupPickerFeatureView: View {
    @Perception.Bindable var store: StoreOf<SubgroupPickerFeature>
    @State var selectedSubgroup: Int?

    var body: some View {
        WithPerceptionTracking {
            Menu {
                Picker("view.subgroupPicker.title", selection: $selectedSubgroup) {
                    ForEach(1...store.maxSubgroup, id: \.self) { subgroup in
                        Label.subgroup(subgroup)
                            .tag(Int?.some(subgroup))
                            .labelStyle(.titleAndIcon)
                    }

                    Label.allSubgroups.tag(Int?.none)
                }
                .tint(nil)
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
