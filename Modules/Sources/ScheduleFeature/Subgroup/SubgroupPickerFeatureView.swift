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
            Picker("Subgroup", selection: viewStore.binding(get: \.selected, send: { .setSelected($0) })) {
                ForEach(1...viewStore.maxSubgroup, id: \.self) { subgroup in
                    Label("\(subgroup)", systemImage: "person.fill")
                        .tag(Int?.some(subgroup))
                        .labelStyle(.titleAndIcon)
                }

                Label("All", systemImage: "person.2").tag(Int?.none)
            }
            .tint(viewStore.selected == nil ? .secondary : .blue)
        }
    }
}
