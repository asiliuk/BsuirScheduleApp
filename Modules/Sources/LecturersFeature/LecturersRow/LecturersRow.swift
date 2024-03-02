import Foundation
import BsuirApi
import ScheduleFeature
import ComposableArchitecture

@Reducer
public struct LecturersRow {
    @ObservableState
    public struct State: Identifiable, Equatable {
        public var id: Int { lector.id }
        public let lector: Employee

        var fullName: String { lector.fio }
        var imageUrl: URL? { lector.photoLink }

        var subtitle: String? {
            lector.academicDepartment?.joined(separator: " · ")
        }

        var subtitle2: String? {
            [lector.degree, lector.rank]
                .compacted()
                .joined(separator: ", ")

        }

        var mark: MarkedScheduleRowFeature.State

        init(lector: Employee) {
            self.lector = lector
            self.mark = .init(source: .lector(lector))
        }
    }

    public enum Action: Equatable {
        case rowTapped
        case mark(MarkedScheduleRowFeature.Action)
    }

    public var body: some ReducerOf<Self> {
        Scope(state: \.mark, action: \.mark) {
            MarkedScheduleRowFeature()
        }
    }
}
