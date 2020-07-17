//
//  ScheduleView.swift
//  BsuirScheduleApp
//
//  Created by Anton Siliuk on 9/28/19.
//  Copyright © 2019 Saute. All rights reserved.
//

import SwiftUI

struct ScheduleView: View {

    enum ScheduleType: Hashable {
        case continuous
        case compact
        case exams
    }

    @ObservedObject var screen: ScheduleScreen
    @State var scheduleType: ScheduleType = .continuous

    var body: some View {
        VStack(spacing: 0) {
            header
            schedule
        }
        .onAppear(perform: screen.schedule.load)
        .navigationBarTitle(Text(screen.name), displayMode: .inline)
    }

    private var header: some View {
        Picker("Тип расписания", selection: $scheduleType) {
            Text("Расписание").tag(ScheduleType.continuous)
            Text("По дням").tag(ScheduleType.compact)
            Text("Экзамены").tag(ScheduleType.exams)
        }
        .pickerStyle(SegmentedPickerStyle())
        .background(Color(.systemBackground))
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
            EmptyState()
        } else {
            ScheduleGridView(
                days: days.map(IdentifiableDay.init),
                makeDayView: { day in
                    ScheduleDay(
                        title: day.title,
                        subtitle: day.subtitle,
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

struct IdentifiableDay: Identifiable {
    var id: String { title }
    let title: String
    let subtitle: String?
    let pairs: [IdentifiablePair]
    let isToday: Bool

    init(day: Day) {
        self.title = day.title
        self.subtitle = day.subtitle
        self.pairs = day.pairs.enumerated().map(IdentifiablePair.init)
        self.isToday = day.isToday
    }
}

struct IdentifiablePair: Identifiable {
    let id: Int
    let pair: Day.Pair
}

struct EmptyState: View {

    var body: some View {
        VStack {
            Spacer()
            Image(systemName: imageNames.randomElement()!).font(.largeTitle)
            Text("Похоже, занятий нет").font(.title)
            Text("Все свободны!").font(.subheadline)
            Spacer()
        }
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
            EmptyState()
        }
    }
}
#endif
