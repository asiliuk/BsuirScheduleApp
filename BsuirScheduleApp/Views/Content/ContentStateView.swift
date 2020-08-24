//
//  ContentStateView.swift
//  BsuirScheduleApp
//
//  Created by Anton Siliuk on 11/8/19.
//  Copyright © 2019 Saute. All rights reserved.
//

import SwiftUI
import Foundation

struct ContentStateView<Value, SubView: View>: View {

    @ObservedObject var content: LoadableContent<Value>
    let makeContent: (Value) -> SubView

    init(content: LoadableContent<Value>, @ViewBuilder makeContent: @escaping (Value) -> SubView) {
        self.content = content
        self.makeContent = makeContent
    }

    @ViewBuilder var body: some View {
        switch content.state {
        case .initial, .loading:
            LoadingState()
        case .error:
            ErrorState(retry: nil)
        case let .some(value):
            makeContent(value)
        }
    }
}

struct LoadingState: View {

    var body: some View {
        VStack {
            Spacer()
            ProgressView()
            Text("Загрузка...")
            Spacer()
        }
    }
}

struct ErrorState: View {

    let retry: (() -> Void)?

    var body: some View {
        VStack {
            Spacer()
            Text("Что-то пошло не так...").font(.title)
            retry.map { Button(action: $0) {
                Text("Повторить попытку")
            } }
            Spacer()
        }
    }
}
