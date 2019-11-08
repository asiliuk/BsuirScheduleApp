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
        if content.isLoading {
            return AnyView(Text("Загрузка..."))
        } else if content.isError {
            return AnyView(Text("Что-то пошло не так..."))
        } else if let value = content.some {
            return AnyView(makeContent(value))
        } else {
            fatalError()
        }
    }
}
