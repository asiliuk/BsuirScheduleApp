import SwiftUI
import ComposableArchitecture

struct SubgroupPickerFeatureView: View {
    struct ViewState: Equatable {
        let selected: Int?
        let maxSubgroup: Int

        init(_ state: SubgroupPickerFeature.State) {
            self.selected = state.selected
            self.maxSubgroup = state.maxSubgroup
        }
    }

    let store: StoreOf<SubgroupPickerFeature>

    var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            Menu {
                Picker("view.subgroupPicker.title", selection: viewStore.binding(get: \.selected, send: { .setSelected($0) })) {
                    ForEach(1...viewStore.maxSubgroup, id: \.self) { subgroup in
                        Label("view.subgroupPicker.subgroup.title\(String(describing: subgroup))", systemImage: "person")
                            .tag(Int?.some(subgroup))
                            .labelStyle(.titleAndIcon)
                    }

                    Label("view.subgroupPicker.allSubgroups.title", systemImage: "person.2").tag(Int?.none)
                }
            } label: {
                if let selected = viewStore.selected {
                    Text("\(Image(systemName: "person.fill"))\(selected)")
                        .monospacedDigit()
                } else {
                    Image(systemName: "person.2")
                }
            }
            .tint(viewStore.selected == nil ? .secondary : .blue)
        }
    }
}
