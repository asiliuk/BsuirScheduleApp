import SwiftUI
import BsuirCore
import BsuirUI
import ScheduleCore
import ReachabilityFeature
import ComposableArchitecture
import ComposableArchitectureUtils

public struct SettingsFeatureView: View {
    public let store: StoreOf<SettingsFeature>
    
    public init(store: StoreOf<SettingsFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: \.isOnTop) { viewStore in
            ScrollableToTopList(isOnTop: viewStore.binding(send: { .view(.setIsOnTop($0)) })) {
                PairFormsColorPickerView(
                    store: store.scope(
                        state: \.pairFormsColorPicker,
                        reducerAction: { .pairFormsColorPicker($0) }
                    )
                )

                Section(header: Text("screen.about.pairPreview.section.header")) {
                    PairPreviewSectionView()
                }
                
                AppIconPickerView(
                    store: store.scope(
                        state: \.appIcon,
                        reducerAction: { .appIcon($0) }
                    )
                )
                
                Section("screen.about.aboutTheApp.section.header") {
                    AboutSectionView(store: store.scope(state: \.appVersion))
                }

                Section("screen.about.reachability.section.header") {
                    ReachabilitySectionView(store: store)
                }
                
                Section("screen.about.data.section.header") {
                    ClearCacheSectionView(store: store)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("screen.settings.navigation.title")
        }
    }
}

// MARK: - Pair Preview Section

private struct PairPreviewSectionView: View {
    var body: some View {
        PairCell(
            from: String(localized: "screen.about.pairPreview.from"),
            to: String(localized: "screen.about.pairPreview.to"),
            interval: "\(String(localized: "screen.about.pairPreview.from"))-\(String(localized: "screen.about.pairPreview.to"))",
            subject: String(localized: "screen.about.pairPreview.subject"),
            weeks: String(localized: "screen.about.pairPreview.weeks"),
            subgroup: String(localized: "screen.about.pairPreview.subgroup"),
            auditory: String(localized: "screen.about.pairPreview.auditory"),
            note: String(localized: "screen.about.pairPreview.note"),
            form: .practice,
            progress: PairProgress(constant: 0.5),
            details: EmptyView()
        )
        .fixedSize(horizontal: false, vertical: true)
        .listRowInsets(EdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2))
        .accessibility(label: Text("screen.about.pairPreview.accessibility.label"))
    }
}

// MARK: - About Section

private struct AboutSectionView: View {
    let store: Store<TextState, SettingsFeature.Action>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Text(viewStore.state)
            LinkButton(title: "Github") { viewStore.send(.githubButtonTapped) }
            LinkButton(title: "Telegram") { viewStore.send(.telegramButtonTapped) }
        }
    }
}

private struct LinkButton: View {
    let title: LocalizedStringKey
    let action: () -> Void

    var body: some View {
        Button(action: action) { Text(title).underline() }
    }
}

// MARK: - Reachability

private struct ReachabilitySectionView: View {
    let store: StoreOf<SettingsFeature>

    var body: some View {
        ReachabilityView(
            store: store.scope(
                state: \.iisReachability,
                reducerAction: { .iisReachability($0) }
            )
        )

        ReachabilityView(
            store: store.scope(
                state: \.appleReachability,
                reducerAction: { .appleReachability($0) }
            )
        )
    }
}

// MARK: - Clear Cache Section

private struct ClearCacheSectionView: View {
    let store: StoreOf<SettingsFeature>

    var body: some View {
        Button("screen.about.data.section.clearCache.button") {
            ViewStore(store.stateless).send(.clearCacheTapped)
        }
        .alert(store.scope(state: \.cacheClearedAlert), dismiss: .view(.cacheClearedAlertDismissed))
    }
}

// MARK: - Previews

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsFeatureView(store: Store(initialState: .init(), reducer: SettingsFeature()))
    }
}
