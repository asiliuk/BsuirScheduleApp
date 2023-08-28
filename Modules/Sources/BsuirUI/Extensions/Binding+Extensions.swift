import SwiftUI

// TODO: Make better way to make sure Binding is called on main queue
extension Binding {
    public func _onMainQueue() -> Binding {
        Binding(
            get: { self.wrappedValue },
            set: { value, transaction in
                DispatchQueue.main.async {
                    self.transaction(transaction).wrappedValue = value
                }
            }
        )
    }
}

