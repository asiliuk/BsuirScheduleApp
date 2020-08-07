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
        ContentStateWithSearchView(
            content: screen.lecturers,
            searchQuery: $screen.searchQuery,
            searchPlaceholder: "Найти преподавателя"
        ) { section in
            Section(header: section.header) {
                ForEach(section.lecturers, id: \.id) { lecturer in
                    NavigationLink(destination: ScheduleView(screen: self.screen.screen(for: lecturer))) {
                        Avatar(url: lecturer.imageURL)
                        Text(lecturer.fullName)
                    }
                }
            }
        }
        .navigationBarTitle("Все преподаватели")
    }
}

private extension AllLecturersScreenGroupSection {
    @ViewBuilder var header: some View {
        switch section {
        case .favorites:
            Text("⭐️ Избранные")
        case .other:
            EmptyView()
        }
    }
}

struct Avatar: View {

    let url: URL?

    var body: some View {
        Group {
            if let url = url {
                RemoteAvatar(url: url, targetSize: targetSize)
            } else {
                UserPlaceholder()
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
