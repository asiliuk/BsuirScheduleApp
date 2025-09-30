import SwiftUI
import BsuirCore
import ScheduleCore

public struct ExamsScheduleWidgetLargeView : View {
    var config: ExamsScheduleWidgetConfiguration
    @Environment(\.widgetRenderingMode) var widgetRenderingMode

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
                                    spellForm: widgetRenderingMode == .accented,
                                    showWeeks: false
                                )
                                .padding(.leading, 10)
                                .padding(.vertical, 2)
                                .background {
                                    let color = Color(uiColor: .secondarySystemBackground)
                                    RoundedRectangle(cornerRadius: 4)
                                        .foregroundStyle(color.opacity(widgetRenderingMode == .accented ? 0.2  : 1))
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
