import Foundation
import ComposableArchitecture
import BsuirApi

@Reducer
struct LoadedLecturersFeature {
    @ObservableState
    struct State {
        var lecturers: [Employee]
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
