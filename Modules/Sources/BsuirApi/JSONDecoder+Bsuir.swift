import Foundation
import BsuirCore

extension JSONDecoder {
    static let bsuirDecoder = mutating(JSONDecoder()) {
        $0.dateDecodingStrategy = .formatted(dateFormatter)
    }

    private static let dateFormatter = mutating(DateFormatter()) {
        $0.dateFormat = "dd.MM.yyyy"
    }
}
