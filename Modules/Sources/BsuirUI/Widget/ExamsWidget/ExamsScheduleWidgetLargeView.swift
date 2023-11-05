import SwiftUI
import BsuirCore
import ScheduleCore

public struct ExamsScheduleWidgetLargeView : View {
    var config: ExamsScheduleWidgetConfiguration

    public init(config: ExamsScheduleWidgetConfiguration) {
        self.config = config
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .lastTextBaseline) {
                if let mainDate {
                    Text(mainDate).font(.headline)
                }
                Spacer()
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    ScheduleIdentifierTitle(title: config.title)
                    ScheduleSubgroupLabel(subgroup: config.subgroup)
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 4)
            .padding(.horizontal, 12)
            .background {
                ExamsScheduleWidgetHeaderBackground()
            }
            .foregroundStyle(Color.white)

            switch config.content {
            case .noPinned:
                NoPinnedScheduleView()
                    .padding(.horizontal)
            case .exams([]):
                NoPairsView()
                    .padding(.horizontal)
            case let .exams(days):
                VStack(alignment: .leading, spacing: 0) {
                    let exams = ExamsToDisplay(
                        days: days,
                        maxVisiblePairsCount: 5,
                        skipFirstPairDate: true
                    )

                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(exams.visible, id: \.pair.id) { (date, pair) in
                            LabeledContent {
                                PairView<EmptyView>(
                                    pair: pair,
                                    isCompact: true,
                                    showWeeks: false
                                )
                                .padding(.leading, 10)
                                .padding(.vertical, 2)
                                .background {
                                    RoundedRectangle(cornerRadius: 4)
                                        .foregroundStyle(Color(uiColor: .secondarySystemBackground))
                                }
                            } label: {
                                if let date {
                                    Text(date.formatted(.compactExamDay))
                                }
                            }
                        }
                    }
                    .padding(.top, 4)

                    Spacer(minLength: 0)

                    RemainingScheduleView(
                        prefix: {
                            guard let exam = exams.upcomingInvisible.first else { return nil }
                            return exam.date?.formatted(.compactExamDay) ?? exam.pair.from
                        }(),
                        subjects: exams.upcomingInvisible.compactMap(\.pair.subject),
                        visibleCount: 3
                    )
                    .padding(.leading, 10)
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
            }
        }
        .labeledContentStyle(ExamsSectionLabeledContentStyle(font: .footnote.bold(), highlightTitle: true))
        .widgetPadding()
        .widgetBackground(Color(.systemBackground))
    }

    private var mainDate: String? {
        guard case let .exams(days) = config.content else { return nil }
        return days.first?.date.formatted(.compactExamDay)
    }
}
