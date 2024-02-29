import Foundation

extension LoadedLecturersFeature.State {
    /// Reset search and scroll state
    mutating func reset() {
        if !searchQuery.isEmpty {
            dismissSearch()
        } else if !isOnTop {
            isOnTop = true
        }
    }
}
