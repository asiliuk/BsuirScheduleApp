import Foundation
import SwiftUI
import Combine

public final class PairProgress: ObservableObject {
    @Published private(set) public var value: Double

    public init(constant value: Double) {
        self.value = value
    }

    public init(_ value: AnyPublisher<Double, Never>) {
        self.value = 0
        value.removeDuplicates().assign(to: &self.$value)
    }
}

// MARK: - Inits

extension PairProgress {
    public static var notStarted: Self {
        .init(constant: 0)
    }

    public static func constant(at date: Date, start: Date, end: Date) -> Self {
        .init(constant: progress(at: date, from: start, to: end))
    }

    public static func updating(start: Date, end: Date) -> Self {
        .init(
            Timer
                .publish(every: 60, on: .main, in: .default)
                .autoconnect()
                .prepend(Date())
                .map { progress(at: $0, from: start, to: end) }
                .eraseToAnyPublisher()
        )
    }

    private static func progress(at date: Date, from: Date, to: Date) -> Double {
        guard date >= from else { return 0 }
        guard date <= to else { return 1 }

        let timeframe = to.timeIntervalSince(from)
        guard timeframe > 0 else { return 0 }

        return date.timeIntervalSince(from) / timeframe
    }
}

// MARK: - Equatable

extension PairProgress: Equatable {
    public static func == (lhs: PairProgress, rhs: PairProgress) -> Bool {
        lhs.value == rhs.value
    }
}
