import SwiftUI
import BsuirCore
import ScheduleCore

public struct ScheduleWidgetEntryAccessoryCircularView: View {
    var config: ScheduleWidgetConfiguration

    public init(config: ScheduleWidgetConfiguration) {
        self.config = config
    }
    
    public var body: some View {
        switch config.content {
        case .noPinned:
            NoPinSymbol()
        case .needsConfiguration:
            Text("⚙️")
        case .pairs(_, []):
            NoPairsView()
        case let .pairs(passed, upcoming):
            let pairs = PairsToDisplay(
                passed: passed,
                upcoming: upcoming,
                maxVisibleCount: 1
            )
            
            ForEach(pairs.visible) { pair in
                PairDetailsView(progress: pair.progress) {
                    pair.subject.map(Text.init(verbatim:))
                } label: {
                    pair.auditory.map(Text.init(verbatim:))
                }
            }
        }
    }
}

private struct PairDetailsView<Content: View, Label: View>: View {
    @ObservedObject var progress: PairProgress
    @ViewBuilder let content: () -> Content
    @ViewBuilder let label: () -> Label
    
    var body: some View {
        return Gauge(value: progress.value) {
            label()
        } currentValueLabel: {
            content()
        }
        .gaugeStyle(.accessoryCircular)
    }
}