import SwiftUI
import ComposableArchitecture

struct PairFormIconsView: View {
    @Bindable var store: StoreOf<PairFormIcons>

    var body: some View {
        Section {
            ForEach(store.pairForms) { pairForm in
                LabeledContent(pairForm.name) {
                    Image(systemName: pairForm.symbolName).foregroundColor(.primary)
                }
            }
        } header: {
            Text("screen.settings.appearance.icons.section.header")
        } footer: {
            Text("screen.settings.appearance.icons.section.footer")
        }

        Section {
            Toggle("screen.settings.appearance.icons.section.alwaysShowToggle.title", isOn: $store.alwaysShowIcon)
        } footer: {
            Text("screen.settings.appearance.icons.section.alwaysShowToggle.footer")
        }
    }
}
