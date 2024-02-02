import SwiftUI
import ComposableArchitecture

struct PairFormIconsView: View {
    @Perception.Bindable var store: StoreOf<PairFormIcons>

    var body: some View {
        Section {
            WithPerceptionTracking {
                ForEach(store.pairForms) { pairForm in
                    LabeledContent(pairForm.name) {
                        Image(systemName: pairForm.symbolName).foregroundColor(.primary)
                    }
                }
            }
        } header: {
            Text("screen.settings.appearance.icons.section.header")
        } footer: {
            Text("screen.settings.appearance.icons.section.footer")
        }

        Section {
            WithPerceptionTracking {
                Toggle("screen.settings.appearance.icons.section.alwaysShowToggle.title", isOn: $store.alwaysShowIcon)
            }
        } footer: {
            Text("screen.settings.appearance.icons.section.alwaysShowToggle.footer")
        }
    }
}
