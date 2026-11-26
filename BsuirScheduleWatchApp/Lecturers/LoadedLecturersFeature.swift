import Foundation
import ComposableArchitecture
import BsuirApi
import Favorites
import ScheduleCore

@Reducer
struct LoadedLecturersFeature {
    @ObservableState
    struct State {
        @SharedReader(.pinnedSchedule) private var pinnedSchedule
        @SharedReader(.favoriteLecturerIDs) private var favoriteLecturerIDs

        var pinnedLecturer: Employee? {
            pinnedSchedule.source?.lector
        }

        var favoriteLecturers: [Employee] {
            favoriteLecturerIDs.compactMap { lecturers[id: $0] }
        }

        var lecturers: IdentifiedArrayOf<Employee>

        init(lecturers: [Employee]) {
            self.lecturers = IdentifiedArray(uniqueElements: lecturers)
        }
    }

    enum Action {
        enum Delegate {
            case showLecturerSchedule(Employee)
        }

        case rowTapped(Employee)
        case delegate(Delegate)
    }

    var body: some Reducer<State, Action> {
        Reduce { _, action in
            switch action {
            case .rowTapped(let lecturer):
                return .send(.delegate(.showLecturerSchedule(lecturer)))
            case .delegate:
                return .none
            }
        }
    }
}
