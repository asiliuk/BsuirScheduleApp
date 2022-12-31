import SwiftUI
import SwiftUINavigation
import ComposableArchitecture
import ComposableArchitectureUtils

struct AppIconFeatureView: View {
    let store: StoreOf<AppIconFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            if viewStore.supportsIconPicking {
                NavigationLink {
                    AppIconPickerView(
                        selection: viewStore.binding(get: \.currentIcon, send: { .view(.iconPicked($0)) })
                    )
                    .alert(store.scope(state: \.alert), dismiss: .alertDismissed)
                    .navigationTitle("screen.settings.appIcon.navigation.title")
                } label: {
                    Label {
                        Text("screen.settings.appIcon.navigation.title")
                    } icon: {
                        AppIconPreviewView(
                            icon: viewStore.currentIcon ?? .plain(.standard),
                            size: 28
                        )
                    }
                }
            }
        }
    }
}

private struct AppIconPickerView: View {
    @Binding var selection: AppIcon?

    var body: some View {
        List {
            AppIconGroupPicker(
                selection: $selection,
                label: Text("screen.settings.appIcon.iconPicker.plain.title"),
                case: /AppIcon.plain
            )

            AppIconGroupPicker(
                selection: $selection,
                label: Text("screen.settings.appIcon.iconPicker.symbol.title"),
                case: /AppIcon.symbol
            )

            AppIconGroupPicker(
                selection: $selection,
                label: Text("screen.settings.appIcon.iconPicker.metall.title"),
                case: /AppIcon.metal
            )
        }
        .pickerStyle(.inline)
        .listStyle(.insetGrouped)
    }
}

private struct AppIconGroupPicker<Icon>: View where Icon: CaseIterable & Hashable & Identifiable, Icon.AllCases: RandomAccessCollection {
    @Binding var selection: AppIcon?
    let label: Text
    let `case`: CasePath<AppIcon, Icon>

    var body: some View {
        Picker(
            selection: $selection.case(`case`),
            label: label
        ) {
            ForEach(Icon.allCases) { icon in
                let appIcon = `case`.embed(icon)
                Label {
                    Text("  ") + Text(appIcon.title)
                } icon: {
                    AppIconPreviewView(icon: appIcon, size: 50)
                }
                .tag(Optional.some(icon))
            }
        }
    }
}
