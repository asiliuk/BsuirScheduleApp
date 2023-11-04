import WidgetKit
import SwiftUI
import Intents
import BsuirApi
import BsuirCore
import ScheduleCore
import Deeplinking
import Favorites
import Combine
import Dependencies

final class ExamsScheduleProvider: TimelineProvider {
    typealias Entry = PinnedScheduleEntry

    func placeholder(in context: Context) -> PinnedScheduleEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (PinnedScheduleEntry) -> Void) {
        completion(.placeholder)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PinnedScheduleEntry>) -> Void) {
        completion(.init(entries: [.placeholder], policy: .never))
    }
}
