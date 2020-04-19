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

    let content: ContentState<Value>
    let makeContent: (Value) -> SubView

    init(content: ContentState<Value>, @ViewBuilder makeContent: @escaping (Value) -> SubView) {
        self.content = content
        self.makeContent = makeContent
    }

    var body: some View {
        switch content {
        case .initial, .loading: return LoadingState().eraseToAnyView()
        case .error: return ErrorState(retry: nil).eraseToAnyView()
        case let .some(value): return makeContent(value).eraseToAnyView()
        }
    }
}

struct LoadingState: View {

    var body: some View {
        VStack {
            Spacer()
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

extension View {

    func eraseToAnyView() -> AnyView { AnyView(self) }
}
