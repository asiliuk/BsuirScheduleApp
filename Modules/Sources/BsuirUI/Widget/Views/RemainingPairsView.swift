import SwiftUI
import BsuirCore
import ScheduleCore

struct RemainingPairsView: View {
    enum ShowTime {
        case first
        case last
        case hide
    }

    let pairs: ArraySlice<PairViewModel>
    let visibleCount: Int
    let showTime: ShowTime

    var body: some View {
        if !pairs.isEmpty {
            HStack {

                time.map(Text.init).font(.system(.footnote, design: .monospaced))

                Circle().frame(width: 8, height: 8)

                Text(morePairs)
                    .font(.footnote)
            }
            .foregroundColor(.secondary)
        }
    }
    
    private var morePairs: String {
        pairs
            .compactMap(\.subject)
            .formatted(
                visibleCount: visibleCount,
                placeholder: { String(localized: "widget.schedule.more.\($0)", bundle: .module) }
            )
    }

    private var time: String? {
        switch showTime {
        case .first:
            return pairs.first?.from
        case .last:
            return pairs.last?.from
        case .hide:
            return nil
        }
    }
}
