import SwiftUI
import BsuirCore
import ScheduleCore

public struct ExamsScheduleWidgetSmallView: View {
    var config: ExamsScheduleWidgetConfiguration

    @Environment(\.widgetRenderingMode) var renderingMode
    @Environment(\.showsWidgetContainerBackground) var showsWidgetBackground

    public init(config: ExamsScheduleWidgetConfiguration) {
        self.config = config
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .lastTextBaseline) {
                ScheduleIdentifierTitle(title: config.title)
                Spacer(minLength: 0)
                ScheduleSubgroupLabel(subgroup: config.subgroup).contrast(2)
            }
            .padding(.top, 10)
            .padding(.bottom, 4)
            .padding(.horizontal, 12)
            .background {
                if renderingMode == .fullColor {
                    ExamsScheduleWidgetHeaderBackground(shouldFillWithExamColor: showsWidgetBackground)
                }
            }
            .foregroundStyle(Color.white)

            switch config.content {
            case .noPinned:
                NoPinnedScheduleView()
                    .padding(.horizontal)
            case .exams(days: []):
                NoPairsView()
                    .padding(.horizontal)
            case .exams(let days):
                Spacer(minLength: 0)

                VStack(alignment: .leading, spacing: 0) {
                    let exams = ExamsToDisplay(
                        days: days,
                        maxVisiblePairsCount: 1
                    )

                    ForEach(exams.visible, id: \.pair.id) { (date, pair) in
                        LabeledContent {
                            PairView(
                                pair: pair,
                                distribution: .vertical,
                                isCompact: showsWidgetBackground,
                                spellForm: renderingMode == .vibrant,
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
                        subjects: exams.upcomingInvisible.compactMap(\.pair.subject),
                        visibleCount: 1
                    )
                }
                .padding(.leading, 12)
                .padding(.trailing, 4)
                .padding(.bottom, 10)
            }
        }
        .labeledContentStyle(ExamsSectionLabeledContentStyle())
        .widgetPadding()
        .widgetBackground(Color(uiColor: .systemBackground))
    }
}
