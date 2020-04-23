//
//  AllLecturersView.swift
//  BsuirScheduleApp
//
//  Created by Anton Siliuk on 9/29/19.
//  Copyright © 2019 Saute. All rights reserved.
//

import SwiftUI

struct AllLecturersView: View {

    @ObservedObject var screen: AllLecturersScreen

    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $screen.searchQuery, placeholder: "Найти преподавателя")

                ContentStateView(content: screen.lecturers) { value in
                    List(value) { lecturer in
                        NavigationLink(destination: ScheduleView(screen: self.screen.screen(for: lecturer))) {
                            RemoteImageView(image: self.screen.image(for: lecturer))
                                .frame(width: 50, height: 50)
                            Text(lecturer.fullName)
                        }
                    }
                }
            }
            .navigationBarTitle("Все преподаватели")
            .onAppear(perform: screen.lecturers.load)
        }
    }
}

struct RemoteImageView: View {

    @ObservedObject var image: RemoteImage

    var body: some View {
        switch image.state {
        case .initial:
            return UserPlaceholder()
                .onAppear(perform: self.image.load)
                .onDisappear(perform: self.image.stop)
                .eraseToAnyView()
        case .loading, .error, .some(nil):
            return UserPlaceholder().eraseToAnyView()
        case let .some(image?):
            return Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .clipShape(Circle())
                .eraseToAnyView()
        }
    }
}

private struct UserPlaceholder: View {

    var body: some View {
        ZStack {
            Circle().foregroundColor(Color.gray)
            Image(systemName: "photo")
        }
    }
}
