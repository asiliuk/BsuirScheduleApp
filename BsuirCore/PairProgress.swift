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

    public static func progress(at date: Date, from: Date, to: Date) -> Double {
        guard date >= from else { return 0 }
        guard date <= to else { return 1 }

        let timeframe = to.timeIntervalSince(from)
        guard timeframe > 0 else { return 0 }

        return date.timeIntervalSince(from) / timeframe
    }
}
