import SwiftUI
import BsuirCore
import BsuirUI
import ScheduleCore
import ReachabilityFeature
import ComposableArchitecture
import ComposableArchitectureUtils

public struct AboutView: View {
    public let store: StoreOf<AboutFeature>
    
    public init(store: StoreOf<AboutFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List {
                ScrollTopIdentifyingView()

                PairFormsColorPickerView(
                    store: store.scope(
                        state: \.pairFormsColorPicker,
                        action: { .pairFormsColorPicker($0) }
                    )
                )

                Section(header: Text("screen.about.pairPreview.section.header")) {
                    PairPreviewSectionView()
                }
                
                AppIconPickerView(
                    store: store.scope(
                        state: \.appIcon,
                        action: { .appIcon($0) }
                    )
                )
                
                Section("screen.about.aboutTheApp.section.header") {
                    AboutSectionView(viewStore: viewStore)
                }

                Section("screen.about.reachability.section.header") {
                    ReachabilitySectionView(store: store)
                }
                
                Section("screen.about.data.section.header") {
                    ClearCacheSectionView(store: store, viewStore: viewStore)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("screen.about.navigation.title")
            .scrollableToTop(isOnTop: viewStore.binding(\.$isOnTop))
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
    let viewStore: ViewStoreOf<AboutFeature>
    
    var body: some View {
        Group {
            Text(viewStore.appVersion ?? TextState("---"))
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
    let store: StoreOf<AboutFeature>

    var body: some View {
        ReachabilityView(
            store: store.scope(
                state: \.iisReachability,
                action: { .iisReachability($0) }
            )
        )

        ReachabilityView(
            store: store.scope(
                state: \.appleReachability,
                action: { .appleReachability($0) }
            )
        )
    }
}

// MARK: - Clear Cache Section

private struct ClearCacheSectionView: View {
    let store: StoreOf<AboutFeature>
    let viewStore: ViewStoreOf<AboutFeature>
    
    var body: some View {
        Button("screen.about.data.section.clearCache.button") {
            viewStore.send(.clearCacheTapped)
        }
        .alert(store.scope(state: \.cacheClearedAlert), dismiss: .view(.cacheClearedAlertDismissed))
    }
}

// MARK: - Previews

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView(store: Store(initialState: .init(), reducer: AboutFeature()))
    }
}
