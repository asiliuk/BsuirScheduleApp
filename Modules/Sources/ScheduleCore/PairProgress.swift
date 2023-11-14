import Foundation
import SwiftUI
import Combine

public final class PairProgress: ObservableObject, Equatable {
    @Published private(set) public var value: Double

    public init(constant value: Double) {
        self.value = value
    }

    public init(_ value: AnyPublisher<Double, Never>) {
        self.value = 0
        value.removeDuplicates().assign(to: &self.$value)
    }

    public convenience init(constantAt date: Date, start: Date, end: Date) {
        self.init(constant: Self.progress(at: date, from: start, to: end))
    }

    public static func progress(at date: Date, from: Date, to: Date) -> Double {
        guard date >= from else { return 0 }
        guard date <= to else { return 1 }

        let timeframe = to.timeIntervalSince(from)
        guard timeframe > 0 else { return 0 }

        return date.timeIntervalSince(from) / timeframe
    }

    public static func == (lhs: PairProgress, rhs: PairProgress) -> Bool {
        lhs.value == rhs.value
    }
}
