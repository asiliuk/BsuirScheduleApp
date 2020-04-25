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
                            Avatar(url: lecturer.imageURL)
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

struct Avatar: View {

    let url: URL?

    var body: some View {
        Group {
            if url == nil {
                UserPlaceholder()
            } else {
                RemoteAvatar(url: url!, targetSize: targetSize)
            }
        }
        .frame(width: targetSize.width, height: targetSize.height)
        .clipShape(Circle())
    }

    private let targetSize = CGSize(width: 50, height: 50)
}

private struct RemoteAvatar: View {

    let url: URL
    let targetSize: CGSize

    var body: some View {
        URLImage(
            url,
            processors: [Resize(size: targetSize, scale: UIScreen.main.scale)],
            placeholder: { _ in UserPlaceholder() },
            content: {
               $0.image
                   .resizable()
                   .aspectRatio(contentMode: .fill)
                   .clipped()
            }
        )
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
