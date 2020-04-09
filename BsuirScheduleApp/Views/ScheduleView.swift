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

            ContentStateView(content: screen.state) { value in
                if self.scheduleType == .everyday {
                    SomeState(days: value.schedule)
                } else if self.scheduleType == .exams {
                    SomeState(days: value.exams)
                }
            }
            Spacer()
        }
        .onAppear(perform: screen.load)
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
                ScheduleCollectionView(weeks: [days])
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
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
        EmptyState()
    }
}
#endif
