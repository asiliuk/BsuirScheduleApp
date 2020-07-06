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
        case everyday
        case exams
    }

    @ObservedObject var screen: ScheduleScreen
    @State var scheduleType: ScheduleType = .everyday

    var body: some View {
        VStack {
            Picker("Тип расписания", selection: $scheduleType) {
                Text("Расписание").tag(ScheduleType.everyday)
                Text("Экзамены").tag(ScheduleType.exams)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            Spacer()

            ContentStateView(content: screen.schedule) { value in
                if self.scheduleType == .everyday {
                    SomeState(days: value.schedule)
                } else if self.scheduleType == .exams {
                    SomeState(days: value.exams)
                }
            }
            Spacer()
        }
        .onAppear(perform: screen.schedule.load)
        .navigationBarTitle(Text(screen.name), displayMode: .inline)
    }
}

struct SomeState: View {

    let days: [Day]

    var body: some View {
        Group {
            if days.isEmpty {
                EmptyState()
            } else {
                #if SDK_iOS_14
                if #available(iOS 14, *) {
                    ScheduleGridView(
                        days: days.map(IdentifiableDay.init),
                        makeDayView: { day in
                            ScheduleDay(
                                title: day.title,
                                pairs: day.pairs,
                                makePairView: { PairCell(pair: $0.pair) }
                            )
                        }
                    )
                }
                #else
                ScheduleCollectionView(weeks: [days])
                    .edgesIgnoringSafeArea(.all)
                #endif
            }
        }
    }
}

struct IdentifiableDay: Identifiable {
    var id: String { title }
    let title: String
    let pairs: [IdentifiablePair]

    init(day: Day) {
        self.title = day.title
        self.pairs = day.pairs.enumerated().map(IdentifiablePair.init)
    }
}

struct IdentifiablePair: Identifiable {
    let id: Int
    let pair: Day.Pair
}

struct EmptyState: View {

    var body: some View {
        VStack {
            Image(systemName: imageNames.randomElement()!).font(.largeTitle)
            Text("Похоже, занятий нет").font(.title)
            Text("Все свободны!").font(.subheadline)
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
