import SwiftUI
import ComposableArchitecture
import BsuirUI
import ScheduleCore

struct PairRowView: View {
    struct ViewState: Equatable {
        let pair: PairViewModel
        let showWeeks: Bool
        let details: PairRowDetails?
        let showingDetails: Bool

        init(_ state: PairRowFeature.State) {
            self.pair = state.pair
            self.showWeeks = state.showWeeks
            self.details = state.details
            self.showingDetails = state.pairDetails != nil
        }
    }

    let store: StoreOf<PairRowFeature>
    @Environment(\.presentsPairDetailsPopover) var presentsPairDetailsPopover

    var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            Button {
                viewStore.send(.rowTapped)
            } label: {
                PairCell(
                    pair: viewStore.pair,
                    showWeeks: viewStore.showWeeks,
                    details: detailsView(pair: viewStore.pair, details: viewStore.details)
                )
            }
            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
            .buttonStyle(PairRowButtonStyle())
            .disabled(presentsPairDetailsPopover)
            .preference(key: PresentsPairDetailsPopoverPreferenceKey.self, value: viewStore.showingDetails)
            .popover(
                store: store.scope(state: \.$pairDetails, action: { .pairDetails($0) }), 
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

// MARK: - Button Style

private struct PairRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.8 : 1)
            .scaleEffect(configuration.isPressed ? 0.99 : 1)
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
