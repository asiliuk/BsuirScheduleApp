import SwiftUI
import BsuirUI
import BsuirCore
import BsuirApi

struct ScheduleView: View {
    enum ScheduleOverlay: Identifiable, Hashable {
        var id: Self { self }
        case lecturer(Employee)
        case group(String)
    }

    @ObservedObject var screen: ScheduleScreen
    @State var scheduleOverlay: ScheduleOverlay?
    @Environment(\.reviewRequestService) var reviewRequestService
    @State var isOnTop: Bool = true

    var body: some View {
        schedule
            .onAppear {
                reviewRequestService?.madeMeaningfulEvent(.scheduleRequested)
                screen.schedule.load()
            }
            .refreshable { await screen.schedule.refresh() }
            .onChange(of: screen.scheduleType) { _ in
                reviewRequestService?.madeMeaningfulEvent(.scheduleModeSwitched)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    HStack {
                        favorite
                        picker
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text(screen.name)
                        .bold()
                        .minimumScaleFactor(0.5)
                        .onTapGesture { isOnTop = true }
                }
            }
            .sheet(item: $scheduleOverlay) { overlay in
                if let screen = scheduleScreen(for: overlay) {
                    ModalNavigationView {
                        ScheduleView(screen: screen)
                    }
                }
            }
    }

    @ViewBuilder private var favorite: some View {
        if let toggleFavorite = screen.toggleFavorite {
            Button(action: { withAnimation {
                if !screen.isFavorite { reviewRequestService?.madeMeaningfulEvent(.addToFavorites) }
                toggleFavorite()
            } }) {
                Image(systemName: screen.isFavorite ? "star.fill" : "star")
            }
            .accessibility(
                label: screen.isFavorite
                    ? Text("screen.schedule.favorite.accessibility.remove")
                    : Text("screen.schedule.favorite.accessibility.add")
            )
            .accentColor(.yellow)
        }
    }

    private var picker: some View {
        Menu {
            Picker("screen.schedule.scheduleTypePicker.title", selection: $screen.scheduleType) {
                ForEach(ScheduleScreen.ScheduleType.allCases, id: \.self) { scheduleType in
                    Label(scheduleType.title, systemImage: scheduleType.imageName)
                }
            }
        } label: {
            Label("screen.schedule.scheduleTypePicker.title", systemImage: screen.scheduleType.imageName)
        }
    }

    private var schedule: some View {
        ContentStateView(content: screen.schedule) { value in
            switch screen.scheduleType {
            case .continuous:
                ContinuousScheduleView(
                    schedule: value.continuous,
                    pairDetails: pairDetails,
                    isOnTop: $isOnTop
                )
            case .compact:
                SomeDayScheduleState(
                    viewModel: value.compact,
                    loading: .never, pairDetails: pairDetails,
                    isOnTop: $isOnTop
                )
            case .exams:
                SomeState(
                    days: value.exams,
                    loading: .never,
                    pairDetails: pairDetails,
                    isOnTop: $isOnTop
                )
            }
        }
    }

    func scheduleScreen(for overlay: ScheduleOverlay) -> ScheduleScreen? {
        switch overlay {
        case let .lecturer(lecturer):
            return screen.employeeSchedule?(lecturer)
        case let .group(group):
            return screen.groupSchedule?(group)
        }
    }

    var pairDetails: ScheduleGridView.PairDetails {
        if screen.employeeSchedule != nil {
            return .lecturers { self.scheduleOverlay = .lecturer($0) }
        }

        if screen.groupSchedule != nil {
            return .groups { self.scheduleOverlay = .group($0) }
        }

        return .nothing
    }
}

private extension ScheduleScreen.ScheduleType {
    var title: LocalizedStringKey {
        switch self {
        case .continuous:
            return "screen.schedule.scheduleType.schedule"
        case .compact:
            return "screen.schedule.scheduleType.byDay"
        case .exams:
            return "screen.schedule.scheduleType.exams"
        }
    }

    var imageName: String {
        switch self {
        case .continuous:
            return "calendar.day.timeline.leading"
        case .compact:
            return "calendar"
        case .exams:
            return "graduationcap"
        }
    }
}

struct ModalNavigationView<Content: View>: View {
    @Environment(\.dismiss) var dismiss

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
                            action: { dismiss() },
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
    let pairDetails: ScheduleGridView.PairDetails
    @Binding var isOnTop: Bool

    var body: some View {
        SomeState(
            days: schedule.days,
            loading: schedule.doneLoading
                ? .finished
                : .loadMore {
                    reviewRequestService?.madeMeaningfulEvent(.moreScheduleRequested)
                    schedule.loadMore()
                },
            pairDetails: pairDetails,
            isOnTop: $isOnTop
        )
    }
}

struct SomeDayScheduleState: View {
    @ObservedObject var viewModel: DayScheduleViewModel
    var loading: ScheduleGridView.Loading
    let pairDetails: ScheduleGridView.PairDetails
    @Binding var isOnTop: Bool
    
    var body: some View {
        SomeState(
            days: viewModel.days,
            loading: loading,
            pairDetails: pairDetails,
            isOnTop: $isOnTop
        )
    }
}

struct SomeState: View {

    let days: [DayViewModel]
    var loading: ScheduleGridView.Loading
    let pairDetails: ScheduleGridView.PairDetails
    @Binding var isOnTop: Bool

    var body: some View {
        if days.isEmpty {
            ScheduleEmptyState()
        } else {
            ScheduleGridView(
                days: days,
                loading: loading,
                pairDetails: pairDetails,
                isOnTop: $isOnTop
            )
        }
    }
}

struct EmptyState: View {
    struct Action {
        let title: LocalizedStringKey
        let action: () -> Void
    }
    let image: Image
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    var action: Action?

    var body: some View {
        VStack {
            Spacer()
            image.font(.largeTitle)
            Text(title).font(.title)
            Text(subtitle).font(.subheadline)
            if let action = action {
                Button(action.title, action: action.action)
                    .buttonStyle(.bordered)
            }
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
            title: "screen.schedule.emptyState.title",
            subtitle: "screen.schedule.emptyState.subtitle"
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
import Combine
struct ScheduleView_Preview: PreviewProvider {

    static var previews: some View {
        Group {
            ScheduleEmptyState()

            EmptyState(
                image: .init(systemName: "rectangle"),
                title: "Title",
                subtitle: "Subtitle",
                action: .init(title: "Test", action: {})
            )

            NavigationView {
                ScheduleView(
                    screen: ScheduleScreen(
                        name: "1010101",
                        isFavorite: Just(true).eraseToAnyPublisher(),
                        toggleFavorite: {},
                        request: Empty().eraseToAnyPublisher(),
                        employeeSchedule: nil,
                        groupSchedule: nil
                    )
                )
            }
        }
    }
}
#endif
