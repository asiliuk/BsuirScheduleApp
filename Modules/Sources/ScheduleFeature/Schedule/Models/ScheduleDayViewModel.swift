import Foundation
import ScheduleCore

struct ScheduleDayViewModel: Equatable, Identifiable {
    let id: UUID
    var title: String
    var subtitle: String?
    var pairs: [PairViewModel]
    var isToday: Bool = false
    var isMostRelevant: Bool = false
}
