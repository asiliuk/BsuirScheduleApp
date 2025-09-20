import SwiftUI
import BsuirUI
import ScheduleCore
import ComposableArchitecture

struct AppearanceFeatureView: View {
    let store: StoreOf<AppearanceFeature>

    var body: some View {
        List {
            Section(header: Text("screen.settings.appearance.pairPreview.section.header")) {
                PairPreviewSectionView()
            }

            WithPerceptionTracking {
                PairFormsColorPickerView(
                    store: store.scope(
                        state: \.pairFormsColorPicker,
                        action: \.pairFormsColorPicker
                    )
                )
            }

            WithPerceptionTracking {
                PairFormIconsView(
                    store: store.scope(
                        state: \.pairFormIcons,
                        action: \.pairFormIcons
                    )
                )
            }
        }
        .navigationTitle("screen.settings.appearance.navigation.title")
    }
}

// MARK: - Pair Preview Section

private struct PairPreviewSectionView: View {
    var body: some View {
        PairCell(
            from: String(localized: "screen.settings.appearance.pairPreview.from"),
            to: String(localized: "screen.settings.appearance.pairPreview.to"),
            interval: "\(String(localized: "screen.settings.appearance.pairPreview.from"))-\(String(localized: "screen.settings.appearance.pairPreview.to"))",
            subject: String(localized: "screen.settings.appearance.pairPreview.subject"),
            weeks: String(localized: "screen.settings.appearance.pairPreview.weeks"),
            subgroup: String(localized: "screen.settings.appearance.pairPreview.subgroup"),
            auditory: String(localized: "screen.settings.appearance.pairPreview.auditory"),
            note: String(localized: "screen.settings.appearance.pairPreview.note"),
            form: .practice,
            progress: PairProgress(constant: 0.5),
            details: EmptyView()
        )
        .fixedSize(horizontal: false, vertical: true)
        .listRowInsets(EdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2))
        .accessibility(label: Text("screen.settings.appearance.pairPreview.accessibility.label"))
        .containerShape(.rect(cornerRadius: 24))
    }
}
