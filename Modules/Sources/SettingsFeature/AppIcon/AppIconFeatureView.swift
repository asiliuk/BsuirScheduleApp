import SwiftUI
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
                            icon: viewStore.currentIcon,
                            size: 28
                        )
                    }
                }
            }
        }
    }
}

private struct AppIconPickerView: View {
    @Binding var selection: AppIcon

    var body: some View {
        List {
            Picker(
                selection: $selection,
                label: Text("screen.settings.appIcon.iconPicker.title")
            ) {
                ForEach(AppIcon.allCases) { icon in
                    AppIconRowPreviewView(icon: icon)
                }
            }
            .pickerStyle(.inline)
        }
        .listStyle(.insetGrouped)
    }
}

private struct AppIconRowPreviewView: View {
    let icon: AppIcon

    var body: some View {
        Label {
            Text("  ") + Text(icon.title)
        } icon: {
            AppIconPreviewView(icon: icon, size: 50)
        }
    }
}
