import SwiftUI
import ComposableArchitecture
import BsuirUI
import ScheduleCore
import Pow

struct PairRowView: View {
    @Perception.Bindable var store: StoreOf<PairRowFeature>
    @Environment(\.presentsPairDetailsPopover) var presentsPairDetailsPopover

    var body: some View {
        WithPerceptionTracking {
            Button {
                store.send(.rowTapped)
            } label: {
                if store.isFiltered {
                    FilteredPairCell(
                        pair: store.pair,
                        showWeeks: store.showWeeks
                    )
                } else {
                    PairCell(
                        pair: store.pair,
                        showWeeks: store.showWeeks,
                        details: detailsView(pair: store.pair, details: store.details)
                    )
                }
            }
            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
            .buttonStyle(PairRowButtonStyle())
            .disabled(presentsPairDetailsPopover)
            .preference(key: PresentsPairDetailsPopoverPreferenceKey.self, value: store.pairDetails != nil)
            .popover(
                item: $store.scope(state: \.pairDetails, action: \.pairDetails),
                content: PairDetailsView.init
            )
        }
    }

    @ViewBuilder
    private func detailsView(pair: PairViewModel, details: PairRowDetails?) -> some View {
        switch details {
        case .lecturers:
            LecturerAvatarsDetails(lecturers: pair.lecturers)
        case .groups:
            GroupPairDetails(groups: pair.groups)
        case nil:
            EmptyView()
        }
    }
}

private struct FilteredPairCell: View {
    let pair: PairViewModel
    let showWeeks: Bool

    var body: some View {
        PairView(
            pair: pair,
            distribution: .oneLine,
            isCompact: true,
            showWeeks: showWeeks
        )
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(uiColor: .systemBackground))
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.secondary.opacity(0.5), style: .filteredPair)
            }
        }
        .foregroundStyle(.secondary)
    }
}

// MARK: - Stroke Style

private extension StrokeStyle {
    static let filteredPair = StrokeStyle(
        lineWidth: 1,
        lineCap: .butt,
        lineJoin: .miter,
        miterLimit: 0,
        dash: [4, 4],
        dashPhase: 0
    )
}

// MARK: - Button Style

private struct PairRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.8 : 1)
            .conditionalEffect(.pushDown, condition: configuration.isPressed)
    }
}

// MARK: - Popover Preference & Environment

/// Pass up the chain flag that some cell presents popover
enum PresentsPairDetailsPopoverPreferenceKey: PreferenceKey {
    static let defaultValue = false

    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }
}

private enum PresentsPairDetailsPopoverEnvironmentKey: EnvironmentKey {
    static let defaultValue = false
}

/// Pass down the environment chain the flag if cell button needs to be disabled due to popover presentation
/// this fix iPad specific bug, when trying to dismiss popover by tap some cell button was activated
extension EnvironmentValues {
    var presentsPairDetailsPopover: Bool {
        get { self[PresentsPairDetailsPopoverEnvironmentKey.self] }
        set { self[PresentsPairDetailsPopoverEnvironmentKey.self] = newValue }
    }
}
