import SwiftUI
import BsuirCore
import ScheduleCore

public struct ExamsWidgetEntryMediumView : View {

    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .lastTextBaseline) {
                Text("23.10.2023").font(.headline)
                Spacer()
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    ScheduleIdentifierTitle(title: "151004")
                    ScheduleSubgroupLabel(subgroup: 2).contrast(2)
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 4)
            .padding(.horizontal, 12)
            .background {
                ExamsScheduleHeaderBackground()
            }
            .foregroundStyle(Color.white)

            VStack(alignment: .leading, spacing: 0) {

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
                    isCompact: true,
                    spellForm: false,
                    details: EmptyView()
                )

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
                    showTime: .first
                )
            }
            .padding(.leading, 12)
            .padding(.trailing, 4)
            .padding(.top, 2)
            .padding(.bottom, 8)
        }
        .labeledContentStyle(ExamsSectionLabeledContentStyle(font: .footnote.bold(), highlightTitle: true))
        .widgetPadding()
        .widgetBackground(Color(.systemBackground))
    }
}
