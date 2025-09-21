import SwiftUI
import BsuirUI
import ComposableArchitecture

struct AppIconLabelNavigationLink: View {
    let value: SettingsFeatureDestination
    let store: StoreOf<AppIconLabel>

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
                                    let icon = store.currentIcon.or(.plain(.liquid))
                                    AppIconPreviewView(
                                        imageName: icon.previewImageName,
                                        size: proxy.size.width,
                                        needsClipping: icon.needsClipping
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
                isPremiumLocked: !store.isPremiumUser,
                isSafeMode: store.isSafeModeEnabled,
                onSafeModeDisableTapped: { store.send(.disableSafeModeTapped) }
            )
            .alert($store.scope(state: \.alert, action: \.alert))
            .navigationTitle("screen.settings.appIcon.navigation.title")
        }
    }
}

private struct AppIconPickerView: View {
    @Binding var selection: AppIcon?
    let isPremiumLocked: Bool
    let isSafeMode: Bool
    var onSafeModeDisableTapped: () -> Void = {}

    var body: some View {
        List {
            AppIconGroupPicker(
                selection: $selection,
                isPremiumLocked: isPremiumLocked,
                isSafeMode: isSafeMode,
                label: "screen.settings.appIcon.iconPicker.plain.title",
                caseKeyPath: \.plain
            )

            AppIconGroupPicker(
                selection: $selection,
                isPremiumLocked: isPremiumLocked,
                isSafeMode: isSafeMode,
                label: "screen.settings.appIcon.iconPicker.symbol.title",
                caseKeyPath: \.symbol
            )

            AppIconGroupPicker(
                selection: $selection,
                isPremiumLocked: isPremiumLocked,
                isSafeMode: isSafeMode,
                label: "screen.settings.appIcon.iconPicker.metall.title",
                caseKeyPath: \.metal
            )

            AppIconGroupPicker(
                selection: $selection,
                isPremiumLocked: isPremiumLocked,
                isSafeMode: isSafeMode,
                label: "screen.settings.appIcon.iconPicker.neon.title",
                caseKeyPath: \.neon
            )

            AppIconGroupPicker(
                selection: $selection,
                isPremiumLocked: isPremiumLocked,
                isSafeMode: isSafeMode,
                label: "screen.settings.appIcon.iconPicker.glitch.title",
                caseKeyPath: \.glitch
            )

            Section {} footer: {
                Text("screen.settings.appIcon.safeMode.text")
                    .gesture(TapGesture(count: 3).onEnded { _ in onSafeModeDisableTapped() })
            }
        }
        .pickerStyle(.inline)
        .listStyle(.insetGrouped)
    }
}

private struct AppIconGroupPicker<Icon: AppIconProtocol>: View {
    @Binding var selection: AppIcon?
    let isPremiumLocked: Bool
    let isSafeMode: Bool
    let label: LocalizedStringKey
    let caseKeyPath: CaseKeyPath<AppIcon, Icon>

    var body: some View {
        let icons = Icon.allCases.filter { !isSafeMode || $0.isSafe }
        if !icons.isEmpty {
            Section(label) {
                ForEach(icons) { icon in
                    AppIconRow(
                        title: icon.title,
                        imageName: icon.previewImageName,
                        needsClipping: icon.needsClipping,
                        isPremiumLocked: icon.isPremium && isPremiumLocked,
                        isSelected: .init(
                            get: {
                                $selection.wrappedValue?[case: caseKeyPath] == icon
                            },
                            set: { newValue, transaction in
                                $selection.transaction(transaction).wrappedValue = newValue ? caseKeyPath(icon) : nil
                            }
                        )
                    )
                }
            }
        }
    }
}

private struct AppIconRow: View {
    let title: LocalizedStringKey
    let imageName: String
    let needsClipping: Bool
    let isPremiumLocked: Bool
    @Binding var isSelected: Bool
    @ScaledMetric var rowHeight: CGFloat = 50

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
                    Text(title).foregroundColor(isPremiumLocked ? .secondary : .primary)
                } icon: {
                    ScaledAppIconPreviewView(
                        imageName: imageName,
                        size: rowHeight,
                        needsClipping: needsClipping
                    )
                }
                .padding(.leading, 16)
            }
        }
        .foregroundColor(.primary)
        .frame(height: rowHeight + 4)
    }
}
