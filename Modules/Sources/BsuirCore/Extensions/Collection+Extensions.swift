import Foundation

extension Collection {
    public func nilOnEmpty() -> Self? {
        return isEmpty ? nil : self
    }
}

extension Collection where Element: Hashable {
    public func uniqueSorted(by sort: (Element, Element) -> Bool) -> [Element] {
        Set(self).sorted(by: sort)
    }
}
