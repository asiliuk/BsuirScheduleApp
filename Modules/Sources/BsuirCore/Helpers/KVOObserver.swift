import Foundation
import Combine

extension NSObject {
    public func bsuirObserve(
        forKeyPath keyPath: String,
        onNewValue: @escaping (Any) -> Void,
        onQueue queue: DispatchQueue = .main
    ) -> AnyCancellable {
        let observer = KVOObserver(keyPath: keyPath) { value in
            queue.async { onNewValue(value) }
        }
        self.addObserver(observer, forKeyPath: keyPath, options: [.new], context: nil)
        return AnyCancellable { [weak self] in
            self?.removeObserver(observer, forKeyPath: keyPath, context: nil)
        }
    }
}

private final class KVOObserver: NSObject {
    let keyPath: String
    let onNewValue: (Any) -> Void

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
        onNewValue(newValue)
    }
}
