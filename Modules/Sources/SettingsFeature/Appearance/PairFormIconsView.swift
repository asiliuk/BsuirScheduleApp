import SwiftUI
import ComposableArchitecture

struct PairFormIconsView: View {
    let store: StoreOf<PairFormIcons>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Section {
                ForEach(viewStore.pairForms) { pairForm in
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
                Toggle("screen.settings.appearance.icons.section.alwaysShowToggle.title", isOn: viewStore.$alwaysShowIcon)
            } footer: {
                Text("screen.settings.appearance.icons.section.alwaysShowToggle.footer")
            }
        }
    }
}
