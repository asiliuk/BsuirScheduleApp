import SwiftUI

@main
struct BsuirScheduleApplication: App {
    @StateObject var state = AppState()

    var body: some Scene {
        WindowGroup {
            RootView(state: state)
                .environment(\.reviewRequestService, state.reviewRequestService)
                .environmentObject(state.pairFormColorService)
        }
    }
}
