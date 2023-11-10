import SwiftUI

struct ExamsScheduleWidgetHeader: View {
    var config: ExamsScheduleWidgetConfiguration
    var showMainDate: Bool = true
    var showBackground: Bool = true
    @EnvironmentObject private var pairFormDisplayService: PairFormDisplayService

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
        .padding(.horizontal, 12)
        .background {
            if showBackground {
                pairFormDisplayService.color(for: .exam).color
            }
        }
        .foregroundStyle(Color.white)
    }

    private var mainDate: String? {
        guard case let .exams(days) = config.content else { return nil }
        return days.first?.date.formatted(.compactExamDay)
    }
}
