import Foundation
import IdentifiedCollections
import BsuirApi

extension GroupsSearch.State {
    mutating func updateSuggestedTokens(for groups: IdentifiedArray<String, StudentGroup>) {
        suggestedTokens = {
            switch tokens.last {
            case nil:
                return groups
                    .map(\.faculty)
                    .uniqueSorted(by: <)
                    .map(StrudentGroupSearchToken.faculty)
            case let .faculty(value):
                return groups
                    .filter { $0.faculty == value }
                    .map(\.speciality)
                    .uniqueSorted(by: <)
                    .map(StrudentGroupSearchToken.speciality)
            case let .speciality(value):
                return groups
                    .filter { $0.speciality == value }
                    .map(\.course)
                    .uniqueSorted(by: { ($0 ?? 0) < ($1 ?? 0) })
                    .map(StrudentGroupSearchToken.course)
            case .course:
                return []
            }
        }()
    }
}
