import SwiftUI
import BsuirCore
import BsuirUI
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
                Section(header: Text("screen.about.colors.section.header")) {
                    PairFormsSectionView()
                }
                
                Section(header: Text("screen.about.pairPreview.section.header")) {
                    PairPreviewSectionView()
                }
                
                AppIconPickerView(
                    store: store.scope(
                        state: \.appIcon,
                        action: { .appIcon($0) }
                    )
                )
                
                Section(header: Text("screen.about.aboutTheApp.section.header")) {
                    AboutSectionView(viewStore: viewStore)
                }
                
                Section(header: Text("screen.about.data.section.header")) {
                    ClearCacheSectionView(store: store, viewStore: viewStore)
                }
            }
            .task { await viewStore.send(.task).finish() }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("screen.about.navigation.title")
        }
    }
}

// MARK: - Form Section

private struct PairFormsSectionView: View {
    var body: some View {
        ForEach(PairViewForm.allCases, id: \.self) { form in
            PairTypeView(name: form.name, form: form)
        }
    }
}

// MARK: - Pair Preview Section

private struct PairPreviewSectionView: View {
    var body: some View {
        PairCell(
            from: "screen.about.pairPreview.from",
            to: "screen.about.pairPreview.to",
            interval: "\(String(localized: "screen.about.pairPreview.from"))-\(String(localized: "screen.about.pairPreview.to"))",
            subject: "screen.about.pairPreview.subject",
            weeks: "screen.about.pairPreview.weeks",
            subgroup: "screen.about.pairPreview.subgroup",
            auditory: "screen.about.pairPreview.auditory",
            note: "screen.about.pairPreview.note",
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
