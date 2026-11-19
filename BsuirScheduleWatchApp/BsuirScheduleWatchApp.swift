import SwiftUI
import ComposableArchitecture

@main
struct BsuirScheduleWatchApp: App {
    @State var store = Store(initialState: ContentFeature.State(), reducer: { ContentFeature() })

    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
        }
    }
}
