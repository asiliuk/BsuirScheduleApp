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
    
    private func shouldShowPlaceholder(for state: URL?) -> AnyView {
        switch state {
        case nil: return AnyView(UserPlaceholder())
        case .some(let url): return AnyView(Avatar(url: url))
        }
    }
    
    @ObservedObject var screen: AllLecturersScreen
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $screen.searchQuery, placeholder: "Найти преподавателя")
                ContentStateView(content: screen.lecturers) { value in
                    List(value) { lecturer in
                        NavigationLink(destination: ScheduleView(screen: self.screen.screen(for: lecturer))) {
                            self.shouldShowPlaceholder(for: self.screen.imageURL(for: lecturer))
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

struct Avatar: View {
    let url: URL
    var body: some View {
        URLImage(url,
                 expireAfter: Date(timeIntervalSinceNow: 31_556_926.0),
                 processors: [ Resize(size: CGSize(width: 50.0,
                                                   height: 50.0), scale: UIScreen.main.scale) ],
                 placeholder: Image(systemName: "photo"),
                 content:  {
                    $0.image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipped()
        })
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

