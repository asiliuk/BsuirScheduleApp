//
//  DeeplinkHandler.swift
//  BsuirScheduleApp
//
//  Created by Anton Siliuk on 28.09.21.
//  Copyright © 2021 Saute. All rights reserved.
//

import Foundation
import BsuirCore
import Combine

final class DeeplinkHandler {
    @Published private var deeplink: Deeplink?

    func handle(url: URL) {
        deeplink = Deeplink(rawValue: url)
    }

    func deeplink(autoresolve: Bool = false) -> AnyPublisher<Deeplink, Never> {
        $deeplink
            .compactMap { $0 }
            .handleEvents(receiveOutput: { [weak self] _ in
                if autoresolve { self?.deeplink = nil }
            })
            .eraseToAnyPublisher()
    }
}
