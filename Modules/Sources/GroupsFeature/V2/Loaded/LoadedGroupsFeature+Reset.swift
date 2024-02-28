import Foundation

extension LoadedGroupsFeature.State {
    /// Reset search and scroll state
    mutating func reset() {
        if search.reset() {
            return
        }

        if !isOnTop {
            isOnTop = true
        }
    }
}
