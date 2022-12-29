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

                NavigationLink {
                    NetworkAndDataFeatureView(
                        store: store.scope(
                            state: \.networkAndData,
                            reducerAction: { .networkAndData($0) }
                        )
                    )
                } label: {
                    Label("screen.settings.networkAndData.navigation.title", systemImage: "network")
                }

                NavigationLink {
                    AboutFeatureView(
                        store: store.scope(
                            state: \.about,
                            reducerAction: { .about($0) }
                        )
                    )
                } label: {
                    Label("screen.settings.about.navigation.title", systemImage: "info.circle")
                }
            }
            .listStyle(.insetGrouped)
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

// MARK: - Previews

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsFeatureView(store: Store(initialState: .init(), reducer: SettingsFeature()))
    }
}
