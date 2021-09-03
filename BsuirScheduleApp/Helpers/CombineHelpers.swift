//
//  CombineHelpers.swift
//  BsuirScheduleApp
//
//  Created by Anton Siliuk on 3/7/20.
//  Copyright © 2020 Saute. All rights reserved.
//

import Combine
import Foundation
import os.log

extension Publisher where Failure == Never {

    func weekAssign<Root: AnyObject>(to keyPath: ReferenceWritableKeyPath<Root, Output>, on root: Root) -> AnyCancellable {
        sink(receiveValue: { [weak root] in root?[keyPath: keyPath] = $0 })
    }
}

struct LogEvents: OptionSet {
    let rawValue: UInt

    static let subscription = LogEvents(rawValue: 1 << 0)
    static let output = LogEvents(rawValue: 1 << 1)
    static let completion = LogEvents(rawValue: 1 << 2)
    static let cancel = LogEvents(rawValue: 1 << 3)
    static let request = LogEvents(rawValue: 1 << 4)

    static let all: LogEvents = [.subscription, .output, .completion, .cancel, .request]
}

extension Publisher {

    func log(_ log: OSLog, identifier: String, events:LogEvents = [.output, .completion]) -> Publishers.HandleEvents<Self> {
        handleEvents(
            receiveSubscription: { _ in
                guard events.contains(.subscription) else { return }
                os_log(.error, log: log, "%{public}@: received Subscription", identifier)
            },
            receiveOutput: { _ in
                guard events.contains(.output) else { return }
                os_log(.error, log: log, "%{public}@: received Output", identifier)
            },
            receiveCompletion: { completion in
                guard events.contains(.completion) else { return }
                switch completion {
                case .finished:
                    os_log(.error, log: log, "%{public}@: received Completion", identifier)
                case let .failure(error):
                    os_log(.error, log: log, "%{public}@: received Failure. %{public}@", identifier, String(describing: error))
                }
            },
            receiveCancel: {
                guard events.contains(.cancel) else { return }
                os_log(.error, log: log, "%{public}@: received Cancel", identifier)
            },
            receiveRequest: { _ in
                guard events.contains(.request) else { return }
                os_log(.error, log: log, "%{public}@: received Request", identifier)
            }
        )
    }
}
