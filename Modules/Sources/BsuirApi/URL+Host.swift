import Foundation

extension URL {
    public var bsr_host: String {
        guard #available(iOS 16.0, *) else { return host! }
        return host()!
    }
}
