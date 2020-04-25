//
//  AllLecturersView.swift
//  BsuirScheduleApp
//
//  Created by Anton Siliuk on 9/29/19.
//  Copyright © 2019 Saute. All rights reserved.
//

import SwiftUI
import URLImage

struct AllLecturersView: View {

    @ObservedObject var screen: AllLecturersScreen

    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $screen.searchQuery, placeholder: "Найти преподавателя")
                ContentStateView(content: screen.lecturers) { value in
                    List(value) { lecturer in
                        NavigationLink(destination: ScheduleView(screen: self.screen.screen(for: lecturer))) {
                            self.screen.imageURL(for: lecturer)
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                            Text(lecturer.fullName)
                        }
                    }
                    .id(UUID())
                }
            }
            .navigationBarTitle("Все преподаватели")
            .onAppear(perform: screen.lecturers.load)
        }
    }
}

struct UserPlaceholder: View {
    var body: some View {
        ZStack {
            Circle().foregroundColor(Color.gray)
            Image(systemName: "photo")
        }
    }
}

