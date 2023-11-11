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
            ExamsScheduleWidgetHeader(config: config)

            switch config.content {
            case .noPinned:
                NoPinnedScheduleView()
                    .padding(.horizontal)
            case .noSchedule:
                NoScheduleView()
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
        .labeledContentStyle(.secondaryExamsSection)
        .widgetBackground(Color(.systemBackground))
    }
}
