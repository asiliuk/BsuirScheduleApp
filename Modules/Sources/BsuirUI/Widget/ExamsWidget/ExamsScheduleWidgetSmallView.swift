import SwiftUI
import BsuirCore
import ScheduleCore

public struct ExamsScheduleWidgetSmallView: View {
    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .lastTextBaseline) {
                ScheduleIdentifierTitle(title: "151004")
                Spacer(minLength: 0)
                ScheduleSubgroupLabel(subgroup: 2).contrast(2)
            }
            .padding(.top, 10)
            .padding(.bottom, 4)
            .padding(.horizontal, 12)
            .background {
                ExamsScheduleWidgetHeaderBackground()
            }
            .foregroundStyle(Color.white)

            VStack(alignment: .leading, spacing: 0) {
                LabeledContent("25.10.2023") {
                    PairView(
                        from: "12:00",
                        to: "14:00",
                        interval: "12:00-13:00",
                        subject: "POIT",
                        weeks: nil,
                        subgroup: nil,
                        auditory: "145 2k",
                        note: "До 15:00",
                        form: .exam,
                        progress: .init(constant: 0.5),
                        distribution: .vertical,
                        isCompact: true,
                        spellForm: false,
                        details: EmptyView()
                    )
                }


                Spacer(minLength: 0)

                RemainingPairsView(
                    pairs: [
                        PairViewModel(
                            from: "14:00",
                            to: "15:00",
                            interval: "14",
                            form: .exam,
                            subject: "KSIS",
                            subjectFullName: "",
                            auditory: nil,
                            note: nil,
                            weeks: nil,
                            subgroup: 2,
                            progress: .init(constant: 1),
                            lecturers: [],
                            groups: []
                        )][...],
                    visibleCount: 1,
                    showTime: .hide
                )
            }
            .padding(.leading, 12)
            .padding(.trailing, 4)
            .padding(.bottom, 10)
        }
        .labeledContentStyle(ExamsSectionLabeledContentStyle())
        .widgetPadding()
        .widgetBackground(Color(uiColor: .systemBackground))
    }
}

struct ExamsSectionLabeledContentStyle: LabeledContentStyle {
    var font: Font = .headline
    var highlightTitle = false

    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            configuration.label
                .font(font)
                .underline(highlightTitle, pattern: .solid, color: .secondary.opacity(0.5))

            configuration.content
        }
        .padding(.top, 4)
    }
}
