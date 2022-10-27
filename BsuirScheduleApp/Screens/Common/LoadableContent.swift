//
//  RemoteImage.swift
//  BsuirScheduleApp
//
//  Created by Anton Siliuk on 3/7/20.
//  Copyright © 2020 Saute. All rights reserved.
//

import Combine
import Foundation
import UIKit
import BsuirApi
import LoadableFeature

typealias ContentState<Value> = LodableContentState<Value>

final class LoadableContent<Value>: ObservableObject {

    @Published private(set) var state: ContentState<Value> = .initial

    init(_ load: AnyPublisher<Value, Error>) {
        self.loadPublisher = Deferred { load }
    }

    func load() {
        switch state {
        case .initial, .error:
            loading = fetch()
                .prepend(.loading)
                .weekAssign(to: \.state, on: self)
        case .loading, .some:
            // Nothing to do
            break
        }
    }

    func stop() {
        loading = nil
    }

    func refresh() async {
        switch state {
        case .error, .some:
            state = await withCheckedContinuation { continuation in
                loading = fetch()
                    .first()
                    .map(Result.success)
                    .sink(receiveValue: continuation.resume(with:))
            }
        case .loading, .initial:
            break
        }
    }

    private func fetch() -> AnyPublisher<ContentState<Value>, Never> {
        loadPublisher
            .map(ContentState.some)
            .receive(on: RunLoop.main)
            .replaceError(with: .error)
            .eraseToAnyPublisher()
    }

    private let loadPublisher: Deferred<AnyPublisher<Value, Error>>
    private var loading: AnyCancellable?
}

extension Publisher {

    func eraseToLoading() -> AnyPublisher<Output, Error> {
        self.mapError { $0 }.eraseToAnyPublisher()
    }
}
