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

    var body: some View {
        switch content {
        case .initial, .loading: return Text("Загрузка...").eraseToAnyView()
        case .error: return Text("Что-то пошло не так...").eraseToAnyView()
        case let .some(value): return makeContent(value).eraseToAnyView()
        }
    }
}

extension View {

    func eraseToAnyView() -> AnyView { AnyView(self) }
}
