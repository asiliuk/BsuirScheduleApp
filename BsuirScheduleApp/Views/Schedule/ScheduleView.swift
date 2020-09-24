import SwiftUI
import BsuirUI

struct ScheduleView: View {

    enum ScheduleType: Hashable {
        case continuous
        case compact
        case exams
    }

    @ObservedObject var screen: ScheduleScreen
    @State var scheduleType: ScheduleType = .continuous

    var body: some View {
        schedule
            .onAppear(perform: screen.schedule.load)
            .navigationBarTitle(Text(screen.name), displayMode: .inline)
            .navigationBarItems(trailing: HStack { favorite; picker })
    }

    private var favorite: some View {
        Button(action: { withAnimation { screen.toggleFavorite() } }) {
            Image(systemName: screen.isFavorite ? "star.fill" : "star")
                .accentColor(.yellow)
                .padding(.horizontal, 4)
        }
        .accessibility(
            label: screen.isFavorite
                ? Text("Убрать из избранного")
                : Text("Добавить в избранное")
        )
    }

    private var picker: some View {
        Menu { EmptyView()
            Picker("Тип расписания", selection: $scheduleType) {
                Text("Расписание").tag(ScheduleType.continuous)
                Text("По дням").tag(ScheduleType.compact)
                Text("Экзамены").tag(ScheduleType.exams)
            }
        } label: {
            Image(systemName: "calendar")
                .padding(.horizontal, 4)
        }
        .accessibility(label: Text("Тип расписания"))
    }

    private var schedule: some View {
        ContentStateView(content: screen.schedule) { value in
            switch scheduleType {
            case .continuous:
                ContinuousScheduleView(schedule: value.continuous)
            case .compact:
                SomeState(days: value.compact)
            case .exams:
                SomeState(days: value.exams)
            }
        }
    }
}

struct ContinuousScheduleView: View {
    @ObservedObject var schedule: ContinuousSchedule

    var body: some View {
        SomeState(
            days: schedule.days,
            loadMore: schedule.loadMore
        )
    }
}

struct SomeState: View {

    let days: [Day]
    var loadMore: (() -> Void)?

    @ViewBuilder var body: some View {
        if days.isEmpty {
            ScheduleEmptyState()
        } else {
            ScheduleGridView(
                days: days.map(IdentifiableDay.init),
                makeDayView: { day in
                    ScheduleDay(
                        title: day.title,
                        subtitle: day.subtitle,
                        isMostRelevant: day.isMostRelevant,
                        isToday: day.isToday,
                        pairs: day.pairs,
                        makePairView: { PairCell(pair: $0.pair) }
                    )
                },
                loadMore: loadMore
            )
        }
    }
}

private extension PairCell {
    init(pair: Day.Pair) {
        self.init(
            from: pair.from,
            to: pair.to,
            subject: pair.subject,
            weeks: pair.weeks,
            subgroup: pair.subgroup,
            auditory: pair.auditory,
            note: pair.note,
            form: PairView.Form(pair.form),
            progress: pair.progress
        )
    }
}

private extension PairView.Form {
    init(_ form: Day.Pair.Form) {
        switch form {
        case .exam: self = .exam
        case .lab: self = .lab
        case .lecture: self = .lecture
        case .practice: self = .practice
        case .unknown: self = .unknown
        }
    }
}

struct IdentifiableDay: Identifiable {
    var id: String { title }
    let title: String
    let subtitle: String?
    let pairs: [IdentifiablePair]
    let isToday: Bool
    let isMostRelevant: Bool

    init(day: Day) {
        self.title = day.title
        self.subtitle = day.subtitle
        self.pairs = day.pairs.enumerated().map(IdentifiablePair.init)
        self.isToday = day.isToday
        self.isMostRelevant = day.isMostRelevant
    }
}

struct IdentifiablePair: Identifiable {
    let id: Int
    let pair: Day.Pair
}

struct EmptyState: View {
    let image: Image
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey

    var body: some View {
        VStack {
            Spacer()
            image.font(.largeTitle)
            Text(title).font(.title)
            Text(subtitle).font(.subheadline)
            Spacer()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(title) + Text(", ") + Text(subtitle))
    }
}

struct ScheduleEmptyState: View {
    var body: some View {
        EmptyState(
            image: Image(systemName: imageNames.randomElement()!),
            title: "Похоже, занятий нет",
            subtitle: "Все свободны!"
        )
    }

    private let imageNames = [
        "sportscourt",
        "film",
        "house",
        "gamecontroller",
        "eyeglasses"
    ]
}

#if DEBUG
struct ScheduleView_Preview: PreviewProvider {

    static var previews: some View {
        Group {
            ScheduleEmptyState()
        }
    }
}
#endif
