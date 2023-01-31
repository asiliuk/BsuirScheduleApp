import Foundation
import BsuirApi
import ScheduleFeature
import ComposableArchitecture

public struct LecturersRow: ReducerProtocol {
    public struct State: Identifiable, Equatable {
        public var id: Int { lector.id }
        public let lector: Employee

        var fullName: String { lector.fio }
        var imageUrl: URL? { lector.photoLink }
        var mark: MarkedScheduleFeature.State

        init(lector: Employee) {
            self.lector = lector
            self.mark = .init(source: .lector(lector))
        }
    }

    public enum Action: Equatable {
        case rowTapped
        case mark(MarkedScheduleFeature.Action)
    }

    public var body: some ReducerProtocol<State, Action> {
        Scope(state: \.mark, action: /Action.mark) {
            MarkedScheduleFeature()
        }
    }
}
