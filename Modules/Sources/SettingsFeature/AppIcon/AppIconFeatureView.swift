import SwiftUI
import BsuirUI
import ComposableArchitecture

struct AppIconFeatureNavigationLink: View {
    let value: SettingsFeatureDestination
    let store: StoreOf<AppIconFeature>

    var body: some View {
        WithPerceptionTracking {
            if store.supportsIconPicking {
                NavigationLink(value: value) {
                    Label {
                        Text("screen.settings.appIcon.navigation.title")
                    } icon: {
                            SettingsRowIcon(fill: .green) {
                                Image(systemName: "info.circle.fill")
                            }
                            .hidden()
                            .overlay {
                                GeometryReader { proxy in
                                    WithPerceptionTracking {
                                        AppIconPreviewView(
                                            imageName: store.currentIcon.or(.plain(.standard)).previewImageName,
                                            size: proxy.size.width
                                        )
                                    }
                                }
                        }
                    }
                }
            }
        }
    }
}

struct AppIconFeatureView: View {
    @Perception.Bindable var store: StoreOf<AppIconFeature>

    var body: some View {
        WithPerceptionTracking {
            AppIconPickerView(
                selection: $store.currentIcon.sending(\.iconPicked),
                isPremiumLocked: store.isPremiumLocked
            )
            .alert($store.scope(state: \.alert, action: \.alert))
            .navigationTitle("screen.settings.appIcon.navigation.title")
            .task { await store.send(.task).finish() }
        }
    }
}

private struct AppIconPickerView: View {
    @Binding var selection: AppIcon?
    let isPremiumLocked: Bool

    var body: some View {
        List {
            AppIconGroupPicker(
                selection: $selection,
                isPremiumLocked: isPremiumLocked,
                label: "screen.settings.appIcon.iconPicker.plain.title",
                casePath: /AppIcon.plain
            )

            AppIconGroupPicker(
                selection: $selection,
                isPremiumLocked: isPremiumLocked,
                label: "screen.settings.appIcon.iconPicker.symbol.title",
                casePath: /AppIcon.symbol
            )

            AppIconGroupPicker(
                selection: $selection,
                isPremiumLocked: isPremiumLocked,
                label: "screen.settings.appIcon.iconPicker.metall.title",
                casePath: /AppIcon.metal
            )

            AppIconGroupPicker(
                selection: $selection,
                isPremiumLocked: isPremiumLocked,
                label: "screen.settings.appIcon.iconPicker.neon.title",
                casePath: /AppIcon.neon
            )

            AppIconGroupPicker(
                selection: $selection,
                isPremiumLocked: isPremiumLocked,
                label: "screen.settings.appIcon.iconPicker.glitch.title",
                casePath: /AppIcon.glitch
            )
        }
        .pickerStyle(.inline)
        .listStyle(.insetGrouped)
    }
}

private struct AppIconGroupPicker<Icon: AppIconProtocol>: View {
    @Binding var selection: AppIcon?
    let isPremiumLocked: Bool
    let label: LocalizedStringKey
    let casePath: AnyCasePath<AppIcon, Icon>

    var body: some View {
        Section(label) {
            ForEach(Icon.allCases) { icon in
                AppIconRow(
                    title: icon.title,
                    imageName: icon.previewImageName,
                    isPremiumLocked: icon.isPremium && isPremiumLocked,
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

private struct AppIconRow: View {
    let title: LocalizedStringKey
    let imageName: String
    let isPremiumLocked: Bool
    @Binding var isSelected: Bool

    var body: some View {
        Button {
            isSelected = true
        } label: {
            LabeledContent {
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                        .font(.title3)
                } else if isPremiumLocked {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(.premiumGradient)
                        .font(.title2)
                }
            } label: {
                Label {
                    Text("  \(Text(title))")
                        .foregroundColor(isPremiumLocked ? .secondary : .primary)
                } icon: {
                    ScaledAppIconPreviewView(imageName: imageName, size: 50)
                }
            }
        }
        .foregroundColor(.primary)
    }
}
