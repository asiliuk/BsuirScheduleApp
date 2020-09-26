import WidgetKit
import SwiftUI
import Intents
import BsuirApi
import BsuirUI
import BsuirCore
import Combine

final class Provider: IntentTimelineProvider, ObservableObject {
    typealias Entry = ScheduleEntry

    func placeholder(in context: Context) -> Entry {
        ScheduleEntry(date: Date(), title: "Some name", pairs: [])
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Entry) -> ()) {
//        requestSnapshotCancellable = requestSchedule(for: configuration)
//            .map { Entry(date: Date(), title: $0.title, pairs: []) }
//            .replaceError(with: Entry(date: Date(), title: "---", pairs: []))
//            .sink(receiveValue: completion)

        requestSnapshotCancellable = mostRelevantSchedule(for: configuration)
            .map { response in Entry(response, at: response.now) }
            .replaceNil(with: Entry(date: Date(), title: "---", pairs: []))
            .replaceError(with: Entry(date: Date(), title: "---", pairs: []))
            .sink(receiveValue: completion)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
//        requestTimelineCancellable = requestSchedule(for: configuration)
//            .map { Entry(date: Date(), title: $0.title, pairs: []) }
//            .replaceError(with: Entry(date: Date(), title: "---", pairs: []))
//            .map { .init(entries: [$0], policy: .atEnd) }
//            .sink(receiveValue: completion)

        requestSnapshotCancellable = mostRelevantSchedule(for: configuration)
            .map { response in Entry(response, at: response.now) }
            .replaceNil(with: Entry(date: Date(), title: "---", pairs: []))
            .replaceError(with: Entry(date: Date(), title: "---", pairs: []))
            .map { .init(entries: [$0], policy: .atEnd) }
            .sink(receiveValue: completion)

//        requestSnapshotCancellable2 = mostRelevantSchedule(for: configuration)
//            .replaceError(with: MostRelevantScheduleResponse(title: "---", now: Date(), date: Date(), pairs: []))
//            .sink(receiveValue: { most in
//                dump(most)
//            })
    }

    fileprivate struct MostRelevantScheduleResponse {
        let title: String
        let now: Date
        let schedule: WeekSchedule.ScheduleElement
    }

    private func mostRelevantSchedule(for configuration: ConfigurationIntent) -> AnyPublisher<MostRelevantScheduleResponse, RequestScheduleError> {
        requestSchedule(for: configuration)
            .compactMap { [calendar] response in
                let now = Date()

                guard let mostRelevantElement = WeekSchedule(schedule: response.schedules, calendar: calendar)
                        .schedule(starting: now, now: now)
                        .first(where: { $0.hasUnfinishedPairs(calendar: calendar, now: now) })
                else { return nil }

                return MostRelevantScheduleResponse(
                    title: response.title,
                    now: now,
                    schedule: mostRelevantElement
                )
            }
            .eraseToAnyPublisher()
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

    private let calendar = Calendar.current
    private var requestSnapshotCancellable2: AnyCancellable?
    private var requestSnapshotCancellable: AnyCancellable?
    private var requestTimelineCancellable: AnyCancellable?
    private let requestManager = RequestsManager.bsuir()
}

private let listFormatter = mutating(ListFormatter()) { $0.locale = Locale(identifier: "ru_BY") }
private let timeFormatter = mutating(DateFormatter()) { $0.timeStyle = .short; $0.dateStyle = .none }

private extension ListFormatter {
    func string<C: Collection>(from values: C, visibleCount: Int) -> String? {
        let visible = values.prefix(visibleCount).map { $0 as Any }
        let remaining = values.count - visibleCount
        guard remaining > 0 else { return string(from: visible) }
        return string(from: visible + ["еще \(remaining)"])
    }
}

struct ScheduleEntry: TimelineEntry {
    typealias Pair = PairViewModel
    let date: Date
    let title: String
    let pairs: [Pair]
}

private extension ScheduleEntry {
    init?(_ response: Provider.MostRelevantScheduleResponse, at date: Date) {
        let remainingPairs = response.schedule.pairs.drop(while: { $0.end <= date })
        guard !remainingPairs.isEmpty else { return nil }
        self.init(
            date: date,
            title: response.title,
            pairs: remainingPairs.map { Pair($0.base, showWeeks: false) }
        )
    }
}

struct ScheduleIdentifierTitle: View {
    let title: String

    var body: some View {
        HStack {
            Image("BsuirSymbol").resizable().scaledToFit().frame(width: 20, height: 20)
            Text(title).font(.subheadline).lineLimit(1)
        }
    }
}

struct NoPairsView: View {
    var body: some View {
        HStack {
            Spacer()
            Text("Пар нет").foregroundColor(.secondary)
            Spacer()
        }
    }
}

struct ScheduleWidgetEntrySmallView : View {
    var entry: Provider.Entry
    var currentPair: Provider.Entry.Pair? { entry.pairs.first }
    var restPairs: ArraySlice<Provider.Entry.Pair> { entry.pairs.dropFirst() }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                ScheduleIdentifierTitle(title: entry.title)
                Spacer(minLength: 0)
            }

            Text("\(entry.date, style: .date)").font(.headline).foregroundColor(.blue)

            Spacer(minLength: 0)

            if let pair = currentPair {
                PairView(pair: pair, distribution: .vertical, isCompact: true)
            } else {
                NoPairsView()
            }


            Spacer(minLength: 0)

            if !restPairs.isEmpty {
                HStack {
                    Circle().frame(width: 8, height: 8)
                    Text(listFormatter.string(from: restPairs.map { $0.subject }, visibleCount: 1) ?? "")
                        .font(.footnote)
                }
                .foregroundColor(.secondary)
            }

        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
    }
}

struct ScheduleWidgetEntryMediumView : View {
    var entry: Provider.Entry
    var pair: Provider.Entry.Pair { entry.pairs[0] }
    var secondPair: Provider.Entry.Pair { entry.pairs[1] }
    var pairs: ArraySlice<Provider.Entry.Pair> { entry.pairs.dropFirst(2) }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            EmptyView()
//            HStack {
//                Text("Сегодня, 24.09").font(.headline).foregroundColor(.blue)
//                Spacer()
//                Image("BsuirSymbol").resizable().scaledToFit().frame(width: 20, height: 20)
//                Text(entry.title).font(.subheadline).lineLimit(1)
//
//            }
//
//            Spacer().frame(height: 4)
//
//
//            VStack(alignment: .leading, spacing: 4) {
//
//                PairView(
//                    from: pair.from,
//                    to: pair.to,
//                    subject: pair.title,
//                    subgroup: "1",
//                    auditory: pair.subtitle,
//                    note: "asasasas as asas",
//                    form: .lecture,
//                    progress: PairProgress(constant: 0.5),
//                    isCompact: true
//                )
//
//                PairView(
//                    from: secondPair.from,
//                    to: secondPair.to,
//                    subject: secondPair.title,
//                    subgroup: "1",
//                    auditory: secondPair.subtitle,
//                    note: "asasasas as asas",
//                    form: .lecture,
//                    progress: PairProgress(constant: 0.5),
//                    isCompact: true
//                )
//
//                if !pairs.isEmpty {
//                    HStack {
//                        Text("12:00").font(.system(.footnote, design: .monospaced))
//                        Circle().frame(width: 8, height: 8)
//                        Text(listFormatter.string(from: pairs.map { $0.title }, visibleCount: 3) ?? "")
//                            .font(.footnote)
//                    }.foregroundColor(.secondary)
//                }
//            }

            Spacer(minLength: 0)
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

struct ScheduleWidgetEntryLargeView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            EmptyView()
//            HStack {
//                Text("Сегодня, 24.09").font(.headline).foregroundColor(.blue)
//                Spacer()
//                Image("BsuirSymbol").resizable().scaledToFit().frame(width: 20, height: 20)
//                Text(entry.title).font(.subheadline).lineLimit(1)
//            }
//
//            VStack(alignment: .leading, spacing: 8) {
//                ForEach(entry.pairs.prefix(6), id: \.title) { pair in
//                    PairView(
//                        from: pair.from,
//                        to: pair.to,
//                        subject: pair.title,
//                        subgroup: "1",
//                        auditory: pair.subtitle,
//                        note: "asasasas as asa as asassaa asas as s",
//                        form: .lecture,
//                        progress: PairProgress(constant: 0.5),
//                        isCompact: true
//                    )
//                    .padding(.leading, 10)
//                    .padding(.vertical, 4)
//                    .background(ContainerRelativeShape().foregroundColor(Color(.secondarySystemBackground)))
//                }
////
////                if !pairs.isEmpty {
////                    HStack {
////                        Text("12:00").font(.system(.footnote, design: .monospaced))
////                        Circle().frame(width: 8, height: 8)
////                        Text(listFormatter.string(from: pairs.map { $0.title }, visibleCount: 3) ?? "")
////                            .font(.footnote)
////                    }.foregroundColor(.secondary)
////                }
//            }
//
//            Spacer(minLength: 0)
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

struct ScheduleWidgetEntryView: View {
    let entry: Provider.Entry
    @Environment(\.widgetFamily) var size

    var body: some View {
        switch size {
        case .systemSmall:
            ScheduleWidgetEntrySmallView(entry: entry)
        case .systemMedium:
            ScheduleWidgetEntryMediumView(entry: entry)
        case .systemLarge:
            ScheduleWidgetEntryLargeView(entry: entry)
        @unknown default:
            EmptyView()
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

        ScheduleWidgetEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemMedium))

        ScheduleWidgetEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }

    static let entry = ScheduleEntry(
        date: Date(),
        title: "Иванов А.Н.",
        pairs: [
            .init(from: "10:00", to: "11:45", form: .lecture, subject: "Философ", auditory: "101-2"),
            .init(from: "10:00", to: "11:45", form: .lecture, subject: "Миапр", auditory: "101-2"),
            .init(from: "10:00", to: "11:45", form: .lecture, subject: "Физра", auditory: "101-2"),
            .init(from: "10:00", to: "11:45", form: .lecture, subject: "ПОИТ", auditory: "101-2"),
            .init(from: "10:00", to: "11:45", form: .lecture, subject: "ОкПрог", auditory: "101-2"),
            .init(from: "10:00", to: "11:45", form: .lecture, subject: "Философ", auditory: "101-2")
        ]
    )
}
