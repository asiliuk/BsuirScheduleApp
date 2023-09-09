import Foundation
import ScheduleCore
import ComposableArchitecture

public struct DaySectionFeature: Reducer {
    public struct State: Equatable, Identifiable {
        public var id: UUID
        var title: String
        var subtitle: String?
        var isToday: Bool
        var pairRows: IdentifiedArrayOf<PairRowFeature.State>

        init(
            id: UUID,
            title: String,
            subtitle: String? = nil,
            isToday: Bool = false,
            showWeeks: Bool = false,
            pairs: [PairViewModel],
            pairRowDetails: PairRowDetails?,
            pairRowDay: PairRowDay
        ) {
            self.id = id
            self.title = title
            self.subtitle = subtitle
            self.isToday = isToday
            self.pairRows = IdentifiedArray(
                uniqueElements: pairs.map { pair in
                    PairRowFeature.State(
                        pair: pair,
                        showWeeks: showWeeks,
                        details: pairRowDetails,
                        day: pairRowDay
                    )
                }
            )
        }
    }

    public enum Action: Equatable {
        case pairRow(id: PairRowFeature.State.ID, action: PairRowFeature.Action)
    }

    public var body: some ReducerOf<Self> {
        EmptyReducer()
            .forEach(\.pairRows, action: /Action.pairRow) {
                PairRowFeature()
            }
    }
}
