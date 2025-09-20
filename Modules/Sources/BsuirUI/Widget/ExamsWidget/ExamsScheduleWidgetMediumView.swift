import SwiftUI
import BsuirCore
import ScheduleCore

public struct ExamsScheduleWidgetMediumView : View {
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
                NoExamsView()
                    .padding(.horizontal)
            case .failed(let refresh):
                ScheduleRequestFailedView(refresh: refresh)
                    .padding(.horizontal)
            case .exams(days: []):
                NoPairsView()
                    .padding(.horizontal)
            case let .exams(days):
                VStack(alignment: .leading, spacing: 0) {
                    let exams = ExamsToDisplay(
                        days: days,
                        maxVisiblePairsCount: 2,
                        skipFirstPairDate: true
                    )

                    ForEach(exams.visible, id: \.pair.id) { (date, pair) in
                        LabeledContent {
                            PairView<EmptyView>(
                                pair: pair,
                                isCompact: true,
                                showWeeks: false
                            )
                        } label: {
                            if let date {
                                Text(date.formatted(.compactExamDay))
                            }
                        }
                    }

                    Spacer(minLength: 0)

                    RemainingScheduleView(
                        prefix: {
                            guard let exam = exams.upcomingInvisible.first else { return nil }
                            return exam.date?.formatted(.compactExamDay) ?? exam.pair.from
                        }(),
                        subjects: exams.upcomingInvisible.compactMap(\.pair.subject),
                        visibleCount: 3
                    )
                }
                .padding(.leading, 12)
                .padding(.trailing, 4)
                .padding(.bottom, 8)
            }
        }
        .labeledContentStyle(.secondaryExamsSection)
        .widgetBackground(Color(.systemBackground))
    }
}
