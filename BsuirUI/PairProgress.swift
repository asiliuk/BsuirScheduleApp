import Foundation
import SwiftUI
import Combine

public final class PairProgress: ObservableObject {
    @Published private(set) var value: Double

    public init(constant value: Double) {
        self.value = value
    }

    public init(_ value: AnyPublisher<Double, Never>) {
        self.value = 0
        value.removeDuplicates().assign(to: &self.$value)
    }
}
