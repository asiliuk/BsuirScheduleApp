import WidgetKit
import SwiftUI
import Intents
import BsuirApi
import Combine

final class Provider: IntentTimelineProvider, ObservableObject {
    typealias Entry = ScheduleEntry

    func placeholder(in context: Context) -> Entry {
        ScheduleEntry(date: Date(), name: "Some name")
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Entry) -> ()) {
        requestSnapshotCancellable = requestSchedule(for: configuration)
            .map { Entry(date: Date(), name: $0.name) }
            .replaceError(with: Entry(date: Date(), name: "---"))
            .sink(receiveValue: completion)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        requestSnapshotCancellable = requestSchedule(for: configuration)
            .map { Entry(date: Date(), name: $0.name, count: $0.schedules.count) }
            .replaceError(with: Entry(date: Date(), name: "---"))
            .map { .init(entries: [$0], policy: .atEnd) }
            .sink(receiveValue: completion)
    }

    private struct ScheduleResponse {
        let name: String
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
                .map { ScheduleResponse(name: $0.studentGroup.name, schedules: $0.schedules) }
                .eraseToAnyPublisher()
        case .lecturer:
            guard let lecturerId = makeId(configuration.lecturer?.identifier) else { return fail }
            return requestManager
                .request(BsuirTargets.EmployeeSchedule(id: lecturerId))
                .mapError(RequestScheduleError.request)
                .map { ScheduleResponse(name: $0.employee.fio, schedules: $0.schedules ?? []) }
                .eraseToAnyPublisher()
        }
    }

    private var requestSnapshotCancellable: AnyCancellable?
    private var requestTimelineCancellable: AnyCancellable?
    private let requestManager = RequestsManager.bsuir()
}

struct ScheduleEntry: TimelineEntry {
    let date: Date
    let name: String
    var count: Int = 0
}

struct ScheduleWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text(entry.date, style: .time)
            Text(entry.name)
            Text("\(entry.count)")
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
        ScheduleWidgetEntryView(entry: ScheduleEntry(date: Date(), name: "010102"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
