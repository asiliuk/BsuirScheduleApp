import Foundation
import SwiftUI

public struct ExamsEmptyView: View {
    @State private var didAppear = false
    private var onScheduleCheckTapped: () -> Void

    public init(onScheduleCheckTapped: @escaping () -> Void) {
        self.onScheduleCheckTapped = onScheduleCheckTapped
    }

    public var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: imageName)
                .symbolEffect(symbolEffect, value: didAppear)
        } description: {
            subtitle
        } actions: {
            Button(.screenScheduleExamsEmptyStateScheduleButtonTitle, action: onScheduleCheckTapped)
        }
        .onAppear { didAppear = true }
    }
    
    private let title: LocalizedStringResource = .screenScheduleExamsEmptyStateTitle
    private let subtitle = Text(.screenScheduleExamsEmptyStateSubtitle)
    private let imageName = "graduationcap"

    private var symbolEffect: some (DiscreteSymbolEffect & SymbolEffect) {
        if #available(iOS 18, watchOS 11, *) {
            return .wiggle.clockwise.wholeSymbol
        } else {
            return .bounce
        }
    }
}
