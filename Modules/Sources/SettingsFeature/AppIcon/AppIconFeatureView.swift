import SwiftUI
import BsuirUI
import SwiftUINavigation
import ComposableArchitecture
import ComposableArchitectureUtils

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
                    send: { .view(.iconPicked($0)) }
                ),
                isPremiumLocked: viewStore.isPremiumLocked
            )
            .alert(store.scope(state: \.alert), dismiss: .alertDismissed)
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
                } icon: {
                    AppIconPreviewView(imageName: imageName, size: 50)
                }
                .opacity(isPremiumLocked ? 0.5 : 1)
            }
        }
        .foregroundColor(.primary)
    }
}
