import SwiftUI
import BsuirUI
import BsuirCore
import BsuirApi

struct ScheduleGridView: View {
    enum PairDetails {
        case lecturers(show: (Employee) -> Void)
        case groups(show: (String) -> Void)
        case nothing
    }

    let days: [DayViewModel]
    var loadMore: (() -> Void)? = nil
    var pairDetails: PairDetails = .nothing
    @Binding var isOnTop: Bool

    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(days) { day in
                    ScheduleDay(
                        title: day.title,
                        subtitle: day.subtitle,
                        isMostRelevant: day.isMostRelevant,
                        isToday: day.isToday,
                        pairs: day.pairs,
                        details: pairDetails
                    )
                }
                .listRowSeparator(.hidden)

                if let load = loadMore {
                    ProgressView()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .onAppear(perform: load)
                }
            }
            .listStyle(.plain)
            // To disable cell celection
            .buttonStyle(PlainButtonStyle())
            .onAppear {
                if isOnTop {
                    proxy.scrollTo(RelevantDayViewID.mostRelevant, anchor: .top)
                }
            }
            .onChange(of: isOnTop) { isOnTop in
                if isOnTop {
                    withAnimation {
                        proxy.scrollTo(RelevantDayViewID.mostRelevant, anchor: .top)
                    }
                }
            }
            .gesture(DragGesture().onChanged { _ in
                isOnTop = false
            })
        }
    }
}

struct ScheduleDay: View {
    let title: String
    let subtitle: String?
    var isMostRelevant: Bool
    let isToday: Bool
    let pairs: [PairViewModel]
    let details: ScheduleGridView.PairDetails

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ScheduleDateTitle(date: title, relativeDate: subtitle, isToday: isToday)

            ForEach(pairs) { pair in
                PairCell(
                    pair: pair,
                    details: detailsView(pair: pair)
                )
            }
        }
        .id(isMostRelevant ? RelevantDayViewID.mostRelevant : .other)
        .padding(.vertical, 10)
    }

    @ViewBuilder private func detailsView(pair: PairViewModel) -> some View {
        switch details {
        case .lecturers(let show):
            LecturerAvatarsDetails(lecturers: pair.lecturers, showDetails: show)
        case .groups(let show):
            GroupPairDetails(groups: pair.groups, showDetails: show)
        case .nothing:
            EmptyView()
        }
    }

    @ViewBuilder private var titleText: some View {
        if let subtitle = subtitle {
            Text("\(Text(subtitle).foregroundColor(isToday ? .blue : .red)), \(title)")
        } else {
            Text(title)
        }
    }
}

private enum RelevantDayViewID: Hashable {
    case mostRelevant
    case other
}

#if DEBUG
extension PairViewModel {
    static func mock(
        from: String = "11:00",
        to: String = "13:30",
        form: Form = .lecture,
        subject: String = "Subject",
        auditory: String = "101-4"
    ) -> Self {
        Self(
            from: from,
            to: to,
            form: form,
            subject: subject,
            auditory: auditory
        )
    }
}

extension DayViewModel {
    static func mock(
        title: String = "01.02.0003",
        pairs: [PairViewModel] = [
            .mock(subject: "Pair 1"),
            .mock(subject: "Pair 10"),
            .mock(subject: "Pair 11"),
            .mock(subject: "Pair 100"),
            .mock(subject: "Pair 101"),
        ]
    ) -> Self {
        Self(
            title: title,
            pairs: pairs
        )
    }
}

struct ScheduleGridView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            schedule()

            ScheduleGridView(
                days: [.mock(title: "06.02.0003")],
                isOnTop: .constant(true)
            )

            schedule()
                .previewLayout(.fixed(width: 812, height: 375))

            schedule()
                .environment(\.sizeCategory, .accessibilityMedium)

            schedule()
                .previewDevice("iPad Pro (11-inch) (2nd generation)")

            schedule()
                .previewDevice("iPad Pro (12.9-inch) (4th generation)")

            daySchedule(.mock())
                .padding()
                .previewLayout(.sizeThatFits)

            daySchedule(.mock())
                .padding()
                .previewLayout(.sizeThatFits)
                .colorScheme(.dark)
                .background(Color.black)
        }
    }

    private static func schedule() -> some View {
        ScheduleGridView(
            days: [
                .mock(title: "01.02.0003", pairs: [
                    .mock(subject: "Pair 1"),
                    .mock(subject: "Pair 10"),
                    .mock(subject: "Pair 11"),
                ]),
                .mock(title: "02.02.0003"),
                .mock(title: "03.02.0003", pairs: [
                    .mock(subject: "Pair 1"),
                    .mock(subject: "Pair 10"),
                ]),
                .mock(title: "04.02.0003"),
                .mock(title: "05.02.0003"),
                .mock(title: "06.02.0003"),
            ],
            isOnTop: .constant(true)
        )
    }

    private static func daySchedule(_ day: DayViewModel) -> some View {
        ScheduleDay(
            title: day.title,
            subtitle: day.subtitle,
            isMostRelevant: false,
            isToday: false,
            pairs: day.pairs,
            details: .nothing
        )
    }
}
#endif
