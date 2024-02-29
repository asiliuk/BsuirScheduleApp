import Foundation

extension LoadedGroupsFeature.State {
    /// Reset search and scroll state
    mutating func reset() {
        if !searchQuery.isEmpty {
            searchQuery = ""
            dismissSearch()
        } else if !isOnTop {
            isOnTop = true
        }
    }
}
