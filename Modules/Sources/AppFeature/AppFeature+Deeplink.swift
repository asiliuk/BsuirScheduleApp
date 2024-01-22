import Foundation
import Deeplinking
import ScheduleFeature
import PremiumClubFeature

extension AppFeature {

    func handleDeeplink(state: inout State, deeplink: Deeplink) {
        switch deeplink {
        case let .pinned(displayType):
            handlePinnedDeeplink(state: &state, deeplinkDisplayType: displayType)
        case .groups:
            state.selection = .groups
            state.groups.reset()
        case let .group(name, displayType):
            handleDeeplink(state: &state, groupName: name, deeplinkDisplayType: displayType)
        case .lecturers:
            state.selection = .lecturers
            state.lecturers.reset()
        case let .lector(id, displayType):
            handleDeeplink(state: &state, lectorId: id, deeplinkDisplayType: displayType)
        case .settings:
            state.selection = .settings
            state.settings.reset()
        case let .premiumClub(source):
            state.selection = .settings
            state.settings.openPremiumClub(source: .init(deeplinkSource: source))
        }
    }

    private func handleDeeplink(
        state: inout State,
        groupName: String,
        deeplinkDisplayType: ScheduleDeeplinkDisplayType?
    ) {
        switch pinnedScheduleService.currentSchedule() {
        case .group(groupName):
            handlePinnedDeeplink(state: &state, deeplinkDisplayType: deeplinkDisplayType)
        case .group, .lector, nil:
            state.selection = .groups
            state.groups.openGroup(named: groupName, displayType: displayType(for: deeplinkDisplayType))
        }
    }

    private func handleDeeplink(
        state: inout State,
        lectorId: Int,
        deeplinkDisplayType: ScheduleDeeplinkDisplayType?
    ) {
        switch pinnedScheduleService.currentSchedule() {
        case .lector(let lector) where lector.id == lectorId:
            handlePinnedDeeplink(state: &state, deeplinkDisplayType: deeplinkDisplayType)
        case .lector, .group, nil:
            state.selection = .lecturers
            state.lecturers.openLector(id: lectorId, displayType: displayType(for: deeplinkDisplayType))
        }
    }

    private func handlePinnedDeeplink(
        state: inout State,
        deeplinkDisplayType: ScheduleDeeplinkDisplayType?
    ) {
        state.selection = .pinned
        state.pinnedTab.switchDisplayType(displayType(for: deeplinkDisplayType))
    }

    private func displayType(for deeplinkDisplayType: ScheduleDeeplinkDisplayType?) -> ScheduleDisplayType {
        switch deeplinkDisplayType {
        case .continuous, nil: .continuous
        case .compact: .compact
        case .exams: .exams
        }
    }
}

// MARK: - PremiumClubFeature.Source

private extension PremiumClubFeature.Source {
    init?(deeplinkSource: PremiumClubDeeplinkSource?) {
        guard let deeplinkSource else { return nil }
        switch deeplinkSource {
        case .appIcon: self = .appIcon
        case .pin: self = .pin
        }
    }
}
