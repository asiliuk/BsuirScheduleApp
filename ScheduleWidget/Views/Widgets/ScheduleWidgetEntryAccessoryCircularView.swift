import SwiftUI
import BsuirCore
import ScheduleCore

@available(iOS 16.0, *)
struct ScheduleWidgetEntryAccessoryCircularView: View {
    var entry: Provider.Entry
    
    var body: some View {
        switch entry.content {
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

@available(iOS 16.0, *)
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
