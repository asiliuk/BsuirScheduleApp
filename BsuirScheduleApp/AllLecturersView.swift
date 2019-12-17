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
            ContentStateView(content: state.lecturers) { value in
                List(value) { lecturer in
                    NavigationLink(destination: LecturerView(state: self.state.state(for: lecturer))) {
                        RemoteImageView(image: self.state.image(for: lecturer))
                            .frame(width: 50, height: 50)
                        Text(lecturer.fullName)
                    }
                }
            }
            .navigationBarTitle("Все преподаватели")
        }
        .onAppear(perform: state.request)
    }
}

struct RemoteImageView: View {

    @ObservedObject var image: Store<RemoteImage.State, RemoteImage.Action>

    var body: some View {
        switch image.value {
        case .initial:
            return UserPlaceholder().onAppear(perform: { self.image.send(.request) }).eraseToAnyView()
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
