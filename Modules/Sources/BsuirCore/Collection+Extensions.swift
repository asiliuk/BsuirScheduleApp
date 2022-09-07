import Foundation

extension Collection {
    public func nilOnEmpty() -> Self? {
        return isEmpty ? nil : self
    }
}
