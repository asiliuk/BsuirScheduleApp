import WidgetKit
import SwiftUI
import Intents
import BsuirApi
import BsuirUI
import Combine

final class Provider: IntentTimelineProvider, ObservableObject {
    typealias Entry = ScheduleEntry

    func placeholder(in context: Context) -> Entry {
        ScheduleEntry(date: Date(), title: "Some name", pairs: [])
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Entry) -> ()) {
        requestSnapshotCancellable = requestSchedule(for: configuration)
            .map { Entry(date: Date(), title: $0.title, pairs: []) }
            .replaceError(with: Entry(date: Date(), title: "---", pairs: []))
            .sink(receiveValue: completion)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        requestSnapshotCancellable = requestSchedule(for: configuration)
            .map { Entry(date: Date(), title: $0.title, pairs: []) }
            .replaceError(with: Entry(date: Date(), title: "---", pairs: []))
            .map { .init(entries: [$0], policy: .atEnd) }
            .sink(receiveValue: completion)
    }

    private struct ScheduleResponse {
        let title: String
        let schedules: [DaySchedule]
    }

    private enum RequestScheduleError: Error {
        case invalidData
        case request(RequestsManager.RequestError)
    }

    private func requestSchedule(for configuration: ConfigurationIntent) -> AnyPublisher<ScheduleResponse, RequestScheduleError> {
        func makeId(_ identifier: String?) -> Int? { identifier.flatMap(Int.init) }
        let fail = Fail<ScheduleResponse, RequestScheduleError>(error: .invalidData).eraseToAnyPublisher()
        switch configuration.type {
        case .unknown, .group:
            guard let groupId = makeId(configuration.groupNumber?.identifier) else { return fail }
            return requestManager
                .request(BsuirTargets.Schedule(agent: .groupID(groupId)))
                .mapError(RequestScheduleError.request)
                .map { ScheduleResponse(title: $0.studentGroup.name, schedules: $0.schedules) }
                .eraseToAnyPublisher()
        case .lecturer:
            guard let lecturerId = makeId(configuration.lecturer?.identifier) else { return fail }
            return requestManager
                .request(BsuirTargets.EmployeeSchedule(id: lecturerId))
                .mapError(RequestScheduleError.request)
                .map { ScheduleResponse(title: $0.employee.fio, schedules: $0.schedules ?? []) }
                .eraseToAnyPublisher()
        }
    }

    private var requestSnapshotCancellable: AnyCancellable?
    private var requestTimelineCancellable: AnyCancellable?
    private let requestManager = RequestsManager.bsuir()
}

struct ScheduleEntry: TimelineEntry {
    struct Pair {
        let from: String
        let to: String
        let title: String
        let subtitle: String
    }
    let date: Date
    let title: String
    let pairs: [Pair]
}

struct ScheduleWidgetEntryView : View {
    var entry: Provider.Entry
    var pair: Provider.Entry.Pair { entry.pairs.first! }

    var body: some View {
        VStack {
            Text(entry.title)
            PairCell(
                from: pair.from,
                to: pair.to,
                subject: pair.title,
                subgroup: nil,
                auditory: pair.subtitle,
                note: nil,
                form: .lecture,
                progress: PairProgress(constant: 0.5)
            )
        }
    }
}

@main
struct ScheduleWidget: Widget {
    let kind: String = "ScheduleWidget"
    @StateObject var provider = Provider()

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: provider) { entry in
            ScheduleWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct ScheduleWidget_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleWidgetEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }

    static let entry = ScheduleEntry(
        date: Date(),
        title: "010102",
        pairs: [
            .init(from: "10:00", to: "11:45", title: "Философия", subtitle: "101-2")
        ]
    )
}
