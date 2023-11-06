import SwiftUI
import BsuirUI
import ComposableArchitecture

struct AppIconFeatureNavigationLink: View {
    struct ViewState: Equatable {
        var supportsIconPicking: Bool
        var currentIcon: AppIcon?

        init(_ state: AppIconFeature.State) {
            supportsIconPicking = state.supportsIconPicking
            currentIcon = state.currentIcon
        }
    }

    let value: SettingsFeatureDestination
    let store: StoreOf<AppIconFeature>

    var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            if viewStore.supportsIconPicking {
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
                                AppIconPreviewView(
                                    imageName: viewStore.currentIcon.or(.plain(.standard)).previewImageName,
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

struct AppIconFeatureView: View {
    struct ViewState: Equatable {
        var currentIcon: AppIcon?
        var isPremiumLocked: Bool

        init(_ state: AppIconFeature.State) {
            currentIcon = state.currentIcon
            isPremiumLocked = state.isPremiumLocked
        }
    }

    let store: StoreOf<AppIconFeature>

    var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            AppIconPickerView(
                selection: viewStore.binding(
                    get: \.currentIcon,
                    send: { .iconPicked($0) }
                ),
                isPremiumLocked: viewStore.isPremiumLocked
            )
            .alert(
                store: store.scope(
                    state: \.$alert,
                    action: { .alert($0) }
                )
            )
            .navigationTitle("screen.settings.appIcon.navigation.title")
            .task { await viewStore.send(.task).finish() }
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
    let casePath: CasePath<AppIcon, Icon>

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
