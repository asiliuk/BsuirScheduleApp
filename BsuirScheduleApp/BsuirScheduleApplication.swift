import SwiftUI

@main
struct BsuirScheduleApplication: App {
    @StateObject var state = AppState(storage: .standard)

    var body: some Scene {
        WindowGroup {
            RootView(state: state)
                .environment(\.reviewRequestService, ReviewRequestService(storage: .standard))
        }
    }
}
