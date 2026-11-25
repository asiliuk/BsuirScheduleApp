import Foundation
import Combine

extension NSObject {
    public func bsuirObserve(
        forKeyPath keyPath: String,
        onQueue queue: DispatchQueue = .main,
        onNewValue: @escaping (Any?) -> Void
    ) -> AnyCancellable {
        let observer = KVOObserver(keyPath: keyPath) { value in
            queue.async { onNewValue(value) }
        }
        self.addObserver(observer, forKeyPath: keyPath, options: [.new], context: nil)
        return AnyCancellable { [weak self] in
            self?.removeObserver(observer, forKeyPath: keyPath, context: nil)
        }
    }

    public func bsuirPublisher(
        forKeyPath keyPath: String,
        options: NSKeyValueObservingOptions = [.new]
    ) -> some Publisher<Any?, Never> {
        KVOPublisher(object: self, keyPath: keyPath, options: options)
    }
}

private final class KVOObserver: NSObject {
    let keyPath: String
    let onNewValue: (Any?) -> Void

    init(keyPath: String, onNewValue: @escaping (Any) -> Void) {
        self.keyPath = keyPath
        self.onNewValue = onNewValue
    }

    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        guard keyPath == self.keyPath, let newValue = change?[.newKey] else { return }
        onNewValue(newValue is NSNull ? nil : newValue)
    }
}

private struct KVOPublisher: Publisher {
    typealias Output = Any?
    typealias Failure = Never

    let object: NSObject
    let keyPath: String
    let options: NSKeyValueObservingOptions

    func receive(subscriber: some Subscriber<Output, Failure>) {
        let subscription = Subscription(object: object, keyPath: keyPath, options: options, subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }
}

private extension KVOPublisher {
    final class Subscription: Combine.Subscription {
        private let keyPath: String
        private let options: NSKeyValueObservingOptions

        private var object: NSObject?
        private var subscriber: (any Subscriber<Output, Failure>)?
        private var observer: KVOObserver?
        private var demand: Subscribers.Demand = .none

        init(
            object: NSObject,
            keyPath: String,
            options: NSKeyValueObservingOptions,
            subscriber: some Subscriber<Output, Failure>
        ) {
            self.object = object
            self.keyPath = keyPath
            self.options = options
            self.subscriber = subscriber
        }

        func request(_ newDemand: Subscribers.Demand) {
            // After cancel() both are nil, so this also covers "cancelled".
            guard let object, subscriber != nil else { return }
            demand += newDemand

            // Register once, on first demand.
            guard observer == nil else { return }
            let observer = KVOObserver(keyPath: keyPath) { [weak self] value in
                guard let self, let subscriber, demand > 0 else { return }
                demand -= 1
                demand += subscriber.receive(value)
            }
            self.observer = observer // before addObserver, so a cancel from `.initial` finds it
            object.addObserver(observer, forKeyPath: keyPath, options: options, context: nil)
        }

        func cancel() {
            subscriber = nil
            if let object = object.take(), let observer = observer.take() {
                object.removeObserver(observer, forKeyPath: keyPath, context: nil)
            }
        }
    }
}
