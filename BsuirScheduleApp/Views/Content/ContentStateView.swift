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
    @ViewBuilder let makeContent: (Value) -> SubView

    @ViewBuilder var body: some View {
        switch content.state {
        case .initial, .loading:
            LoadingState()
        case .error:
            ErrorState(retry: { content.load() })
        case let .some(value):
            makeContent(value)
        }
    }
}

struct LoadingState: View {

    var body: some View {
        VStack(spacing: 8) {
            Spacer()
            ProgressView()
            Text("view.loadingState.title")
            Spacer()
        }
    }
}

struct ErrorState: View {

    let retry: (() -> Void)?

    var body: some View {
        VStack {
            Spacer()
            Text("view.errorState.title").font(.title)
            retry.map {
                Button(action: $0) {
                    Text("view.errorState.button.label")
                }
                .buttonStyle(.bordered)
            }
            Spacer()
        }
    }
}

struct ErrorState_Previews: PreviewProvider {
    static var previews: some View {
        ErrorState(retry: nil)
        ErrorState(retry: {})
    }
}
