import Foundation

extension LoadedGroupsFeature.State {
    /// Reset search and scroll state
    mutating func reset() {
        if !searchQuery.isEmpty {
            searchQuery = ""
            searchDismiss += 1
            return
        }

        if !isOnTop {
            isOnTop = true
        }
    }
}
