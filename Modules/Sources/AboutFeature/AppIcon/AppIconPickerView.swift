import SwiftUI
import ComposableArchitecture
import ComposableArchitectureUtils

struct AppIconPickerView: View {
    let store: StoreOf<AppIconPickerReducer>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            if viewStore.supportsIconPicking {
                Section(header: Text("screen.about.appearance.section.header")) {
                    Picker(
                        selection: viewStore.binding(get: \.currentIcon, send: { .view(.iconPicked($0)) }),
                        label: Text("screen.about.appearance.iconPicker.title")
                    ) {
                        ForEach(AppIcon.allCases) { icon in
                            HStack {
                                AppIconView(icon: icon, defaultIcon: viewStore.defaultIcon)
                                Text("  ") + Text(icon.title)
                            }
                        }
                    }
                }
                .task { await viewStore.send(.task).finish() }
                .alert(store.scope(state: \.alert), dismiss: .alertDismissed)
            }
        }
    }
}
