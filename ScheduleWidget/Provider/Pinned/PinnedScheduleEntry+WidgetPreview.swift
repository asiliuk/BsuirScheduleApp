#if DEBUG
import Foundation
import BsuirUI

extension PinnedScheduleEntry {
    static let widgetPreview = PinnedScheduleEntry(
        date: Date().addingTimeInterval(3600 * 20),
        config: PinnedScheduleWidgetConfiguration(
            title: "Иванов АН",
            subgroup: 1,
            content: .pairs(
                passed: [
                    .init(
                        from: "10:00",
                        to: "11:45",
                        interval: "10:00-11:45",
                        form: .practice,
                        subject: "Миапр1",
                        subjectFullName: "Миапр1",
                        auditory: "101-2"
                    ),
                    .init(
                        from: "10:05",
                        to: "11:45",
                        interval: "10:05-11:45",
                        form: .practice,
                        subject: "Философ1",
                        subjectFullName: "Философ1",
                        auditory: "101-2"
                    ),
                    .init(
                        from: "10:10",
                        to: "11:45",
                        interval: "10:10-11:45",
                        form: .practice,
                        subject: "Миапр1",
                        subjectFullName: "Миапр1",
                        auditory: "101-2"
                    ),

                ],
                upcoming: [
                    .init(
                        from: "10:15",
                        to: "11:45",
                        interval: "10:15-11:45",
                        form: .lecture,
                        subject: "Философ",
                        subjectFullName: "Философ",
                        auditory: "101-2", progress: .init(constant: 0.35)
                    ),
                    .init(
                        from: "10:20",
                        to: "11:45",
                        interval: "10:20-11:45",
                        form: .lecture,
                        subject: "Миапр",
                        subjectFullName: "Миапр",
                        auditory: "101-2"
                    ),
                    .init(
                        from: "10:25",
                        to: "11:45",
                        interval: "10:25-11:45",
                        form: .lecture,
                        subject: "Физра",
                        subjectFullName: "Физра",
                        auditory: "101-2"
                    ),
                    .init(
                        from: "10:30",
                        to: "11:45",
                        interval: "10:30-11:45",
                        form: .lecture,
                        subject: "ПОИТ",
                        subjectFullName: "ПОИТ",
                        auditory: "101-2"
                    ),
                    .init(
                        from: "10:35",
                        to: "11:45",
                        interval: "10:35-11:45",
                        form: .lecture,
                        subject: "ОкПрог",
                        subjectFullName: "ОкПрог",
                        auditory: "101-2"
                    ),
                    .init(
                        from: "10:40",
                        to: "11:45",
                        interval: "10:40-11:45",
                        form: .lecture,
                        subject: "Философ",
                        subjectFullName: "Философ",
                        auditory: "101-2"
                    ),
                    .init(
                        from: "10:45",
                        to: "11:45",
                        interval: "10:45-11:45",
                        form: .lecture,
                        subject: "Философ",
                        subjectFullName: "Философ",
                        auditory: "101-2"
                    ),
                ]
            )
        )
    )
}
#endif
