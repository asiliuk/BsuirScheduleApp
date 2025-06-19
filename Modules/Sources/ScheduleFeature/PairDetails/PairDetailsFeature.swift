import Foundation
import ComposableArchitecture
import ScheduleCore
import BsuirApi

@Reducer
public struct PairDetailsFeature {
    @ObservableState
    public struct State {
        var pair: PairViewModel
        var rowDetails: PairRowDetails?
        var rowDay: PairRowDay
        var photoPreview: URL?
    }

    public enum Action {
        public enum Delegate {
            case showGroupSchedule(String)
            case showLectorSchedule(Employee)
        }

        case closeButtonTapped
        case groupTapped(String)
        case lectorTapped(Employee)
        case lectorPhotoTapped(Employee)
        case setPhotoPreview(URL?)
        case delegate(Delegate)
    }

    @Dependency(\.dismiss) var dismiss

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .closeButtonTapped:
                return .run { _ in await dismiss() }

            case .groupTapped(let name):
                return .send(.delegate(.showGroupSchedule(name)))

            case .lectorTapped(let employee):
                return .send(.delegate(.showLectorSchedule(employee)))

            case .lectorPhotoTapped(let employee):
                state.photoPreview = employee.photoLink
                return .none

            case .setPhotoPreview(let url):
                state.photoPreview = url
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
