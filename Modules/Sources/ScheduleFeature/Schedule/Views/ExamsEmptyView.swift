import Foundation
import SwiftUI
import LoadableFeature

struct ExamsEmptyView: View {
    @State var didAppear = false
    var onScheduleCheckTapped: () -> Void = {}

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: imageName)
                .symbolEffect(symbolEffect, value: didAppear)
        } description: {
            subtitle
        } actions: {
            Button("screen.schedule.exams.emptyState.schedule.button.title", action: onScheduleCheckTapped)
        }
        .onAppear { didAppear = true }
    }
    
    private let title: LocalizedStringKey = "screen.schedule.exams.emptyState.title"
    private let subtitle = Text("screen.schedule.exams.emptyState.subtitle")
    private let imageName = "graduationcap"

    @available(iOS 17.0, *)
    private var symbolEffect: some (DiscreteSymbolEffect & SymbolEffect) {
        if #available(iOS 18, *) {
            return .wiggle.clockwise.wholeSymbol
        } else {
            return .bounce
        }
    }
}
