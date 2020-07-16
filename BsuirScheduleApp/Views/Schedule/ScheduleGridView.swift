import SwiftUI

struct ScheduleGridView<DayModel: Identifiable, DayView: View>: View {
    let days: [DayModel]
    let makeDayView: (DayModel) -> DayView

    var body: some View {
        ScrollView {
            LazyVGrid(columns: gridColumns,  spacing: 24) {
                ForEach(days, content: makeDayView)
                    .padding(.horizontal)
            }
        }
    }

    private var gridColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 300, maximum: 500), spacing: 24, alignment: .top)]
    }
}

struct ScheduleDay<PairModel: Identifiable, PairView: View>: View {
    let title: String
    let pairs: [PairModel]
    let makePairView: (PairModel) -> PairView

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.headline)
            ForEach(pairs) {
                makePairView($0)
            }
        }
    }
}

#if DEBUG
struct MockPair: Identifiable {
    let id = UUID()
    let name: String
}

struct MockDay: Identifiable {
    let id = UUID()
    var title: String = "01.02.0003"
    var pairs: [MockPair] = [
        MockPair(name: "Pair 1"),
        MockPair(name: "Pair 10"),
        MockPair(name: "Pair 11"),
        MockPair(name: "Pair 100"),
        MockPair(name: "Pair 101")
    ]
}

struct ScheduleGridView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            schedule()

            schedule()
                .previewLayout(.fixed(width: 812, height: 375))

            schedule()
                .environment(\.sizeCategory, .accessibilityMedium)

            schedule()
                .previewDevice("iPad Pro (11-inch) (2nd generation)")
            schedule()
                .previewDevice("iPad Pro (12.9-inch) (4th generation)")

            daySchedule(.init())
                .padding()
                .previewLayout(.sizeThatFits)

            daySchedule(.init())
                .padding()
                .previewLayout(.sizeThatFits)
                .colorScheme(.dark)
                .background(Color.black)
        }
    }

    private static func schedule() -> some View {
        ScheduleGridView(
            days: [
                MockDay(title: "01.02.0003", pairs: [
                    MockPair(name: "Pair 1"),
                    MockPair(name: "Pair 10"),
                    MockPair(name: "Pair 11"),
                ]),
                MockDay(title: "02.02.0003"),
                MockDay(title: "03.02.0003", pairs: [
                    MockPair(name: "Pair 1"),
                    MockPair(name: "Pair 10"),

                ]),
                MockDay(title: "04.02.0003"),
                MockDay(title: "05.02.0003"),
                MockDay(title: "06.02.0003"),
            ],
            makeDayView: daySchedule
        )
    }

    private static func daySchedule(_ day: MockDay) -> some View {
        ScheduleDay(
            title: day.title,
            pairs: day.pairs,
            makePairView: pairCell
        )
    }

    private static func pairCell(_ pair: MockPair) -> some View {
        PairCell(
            from: "9:00",
            to: "11:30",
            subject: pair.name,
            weeks: "1,2",
            note: "Пара проходит в подвале. ",
            form: .lab
        )
    }
}
#endif
