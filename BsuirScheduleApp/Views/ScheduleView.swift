//
//  ScheduleView.swift
//  BsuirScheduleApp
//
//  Created by Anton Siliuk on 9/28/19.
//  Copyright © 2019 Saute. All rights reserved.
//

import SwiftUI

struct ScheduleView: View {

    @ObservedObject var screen: ScheduleScreen

    var body: some View {
        ContentStateView(content: screen.state) { value in
            if value.isEmpty {
                EmptyState()
            } else {
                ScheduleCollectionView(weeks: [value])
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .onAppear(perform: screen.load)
        .navigationBarTitle(Text(screen.name), displayMode: .inline)
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
