import SwiftUI

struct ExamsScheduleWidgetHeader: View {
    var config: ExamsScheduleWidgetConfiguration
    var showMainDate: Bool = true
    var showBackground: Bool = true
    @EnvironmentObject private var pairFormDisplayService: PairFormDisplayService
    @Environment(\.widgetRenderingMode) var widgetRenderingMode

    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            if showMainDate {
                mainDate.map(Text.init).font(.headline)
                Spacer()
            }

            HStack(alignment: .lastTextBaseline, spacing: 4) {
                ScheduleIdentifierTitle(title: config.title)
                if !showMainDate { Spacer(minLength: 10) }
                ScheduleSubgroupLabel(subgroup: config.subgroup)
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 4)
        .padding(.horizontal, showBackground ? 12 : 4)
        .background {
            if showBackground {
                let color = pairFormDisplayService.color(for: .exam).color
                widgetRenderingMode == .accented ? color.opacity(0.3) : color
            }
        }
        .foregroundStyle(Color.white)
    }

    private var mainDate: String? {
        guard case let .exams(days) = config.content else { return nil }
        return days.first?.date.formatted(.compactExamDay)
    }
}

#Preview {
    ExamsScheduleWidgetHeader(config: .noPinned())
        .environmentObject(PairFormDisplayService.noop)
}
