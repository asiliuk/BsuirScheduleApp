import SwiftUI
import BsuirUI
import BsuirCore
import BsuirApi

struct ScheduleView: View {

    enum ScheduleType: Hashable {
        case continuous
        case compact
        case exams
    }

    @ObservedObject var screen: ScheduleScreen
    @State var scheduleType: ScheduleType = .continuous
    @State var employeeSchedule: Employee?
    @Environment(\.reviewRequestService) var reviewRequestService

    var body: some View {
        schedule
            .onAppear {
                reviewRequestService?.madeMeaningfulEvent(.scheduleRequested)
                screen.schedule.load()
            }
            .onChange(of: scheduleType) { _ in
                reviewRequestService?.madeMeaningfulEvent(.scheduleModeSwitched)
            }
            .navigationTitle(Text(screen.name))
            .navigationBarTitleDisplayMode(.inline)
            // Uses deprecated API here to use .yellow as accent color for favorites
            // .toolbar API makes all buttons blue
            .navigationBarItems(trailing: HStack {
                favorite
                picker
            })
            .sheet(item: $employeeSchedule) { item in
                screen.employeeSchedule.map { makeScreen in
                    ModalNavigationView {
                        ScheduleView(screen: makeScreen(item))
                    }
                }
            }
    }

    private var favorite: some View {
        Button(action: { withAnimation {
            if !screen.isFavorite { reviewRequestService?.madeMeaningfulEvent(.addToFavorites) }
            screen.toggleFavorite()
        } }) {
            Image(systemName: screen.isFavorite ? "star.fill" : "star")
                .padding(.horizontal, 4)
        }
        .accessibility(
            label: screen.isFavorite
                ? Text("Убрать из избранного")
                : Text("Добавить в избранное")
        )
        .accentColor(.yellow)
    }

    private var picker: some View {
        Menu {
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
                ContinuousScheduleView(schedule: value.continuous, showDetails: showDetails)
            case .compact:
                SomeState(days: value.compact, showDetails: showDetails)
            case .exams:
                SomeState(days: value.exams, showDetails: showDetails)
            }
        }
    }

    var showDetails: ((Employee) -> Void)? {
        guard screen.employeeSchedule != nil else { return nil }
        return { self.employeeSchedule = $0 }
    }
}

struct ModalNavigationView<Content: View>: View {
    @Environment(\.presentationMode) var presentationMode

    let content: () -> Content

    init(@ViewBuilder _ content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        NavigationView {
            content()
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(
                            action: { presentationMode.wrappedValue.dismiss() },
                            label: { Image(systemName: "xmark") }
                        )
                    }
                }
        }
    }
}

struct ContinuousScheduleView: View {
    @ObservedObject var schedule: ContinuousSchedule
    @Environment(\.reviewRequestService) var reviewRequestService
    let showDetails: ((Employee) -> Void)?

    var body: some View {
        SomeState(
            days: schedule.days,
            loadMore: {
                reviewRequestService?.madeMeaningfulEvent(.moreScheduleRequested)
                schedule.loadMore()
            },
            showDetails: showDetails
        )
    }
}

struct SomeState: View {

    let days: [DayViewModel]
    var loadMore: (() -> Void)?
    let showDetails: ((Employee) -> Void)?

    @ViewBuilder var body: some View {
        if days.isEmpty {
            ScheduleEmptyState()
        } else {
            ScheduleGridView(
                days: days,
                loadMore: loadMore,
                showDetails: showDetails
            )
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

    init(day: DayViewModel) {
        self.title = day.title
        self.subtitle = day.subtitle
        self.pairs = day.pairs.enumerated().map(IdentifiablePair.init)
        self.isToday = day.isToday
        self.isMostRelevant = day.isMostRelevant
    }
}

struct IdentifiablePair: Identifiable {
    let id: Int
    let pair: PairViewModel
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
