//
//  AllLecturersView.swift
//  BsuirScheduleApp
//
//  Created by Anton Siliuk on 9/29/19.
//  Copyright © 2019 Saute. All rights reserved.
//

import SwiftUI

struct AllLecturersView: View {

    @ObservedObject var state: AllLecturersState

    var body: some View {
        NavigationView {
            Group {
                if state.lecturers.isEmpty {
                    Text("Загрузка...")
                } else {
                    List(state.lecturers) { lecturer in
                        NavigationLink(destination: LecturerView(state: self.state.state(for: lecturer))) {
                            Text(lecturer.fullName)
                        }
                    }
                }
            }
            .navigationBarTitle("Все преподаватели")
        }.onAppear(perform: state.request)
    }
}
