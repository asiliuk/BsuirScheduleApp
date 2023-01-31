import SwiftUI
import BsuirUI
import SwiftUINavigation
import ComposableArchitecture
import ComposableArchitectureUtils

struct AppIconFeatureNavigationLink: View {
    let value: SettingsFeatureDestination
    let store: StoreOf<AppIconFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            if viewStore.supportsIconPicking {
                NavigationLink(value: value) {
                    Label {
                        Text("screen.settings.appIcon.navigation.title")
                    } icon: {
                        AppIconPreviewView(
                            imageName: viewStore.currentIcon.or(.plain(.standard)).appIcon.previewImageName,
                            size: 28
                        )
                    }
                }
            }
        }
    }
}

struct AppIconFeatureView: View {
    let store: StoreOf<AppIconFeature>

    var body: some View {
        WithViewStore(store, observe: \.currentIcon) { viewStore in
            AppIconPickerView(
                selection: viewStore.binding(send: { .view(.iconPicked($0)) })
            )
            .alert(store.scope(state: \.alert), dismiss: .alertDismissed)
            .navigationTitle("screen.settings.appIcon.navigation.title")
        }
    }
}

private struct AppIconPickerView: View {
    @Binding var selection: AppIcon?

    var body: some View {
        List {
            AppIconGroupPicker(
                selection: $selection,
                label: "screen.settings.appIcon.iconPicker.plain.title",
                casePath: /AppIcon.plain
            )

            AppIconGroupPicker(
                selection: $selection,
                label: "screen.settings.appIcon.iconPicker.symbol.title",
                casePath: /AppIcon.symbol
            )

            AppIconGroupPicker(
                selection: $selection,
                label: "screen.settings.appIcon.iconPicker.metall.title",
                casePath: /AppIcon.metal
            )
        }
        .pickerStyle(.inline)
        .listStyle(.insetGrouped)
    }
}

private struct AppIconGroupPicker<Icon: AppIconProtocol>: View {
    @Binding var selection: AppIcon?
    let label: LocalizedStringKey
    let casePath: CasePath<AppIcon, Icon>

    var body: some View {
        Section(label) {
            ForEach(Icon.allCases) { icon in
                AppIconRow(
                    icon: icon,
                    isSelected: .init(
                        get: { $selection.wrappedValue.flatMap(casePath.extract(from:)) == icon },
                        set: { newValue, transaction in
                            $selection.transaction(transaction).wrappedValue = newValue ? casePath.embed(icon) : nil
                        }
                    )
                )
            }
        }
    }
}

private struct AppIconRow<Icon: AppIconProtocol>: View {
    let icon: Icon
    @Binding var isSelected: Bool

    var body: some View {
        Button {
            isSelected = true
        } label: {
            LabeledContent {
                if icon.isPremium {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(.premiumGradient)
                        .font(.title2)
                } else if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                        .font(.title3)
                }
            } label: {
                Label {
                    Text("  \(Text(icon.title))")
                } icon: {
                    AppIconPreviewView(imageName: icon.previewImageName, size: 50)
                }
                .opacity(icon.isPremium ? 0.5 : 1)
            }
        }
        .foregroundColor(.primary)
    }
}
