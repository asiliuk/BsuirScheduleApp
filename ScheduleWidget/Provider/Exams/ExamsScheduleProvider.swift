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
    typealias Entry = ExamsScheduleEntry

    func placeholder(in context: Context) -> ExamsScheduleEntry {
        .preview
    }

    func getSnapshot(in context: Context, completion: @escaping (ExamsScheduleEntry) -> Void) {
        completion(.preview)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ExamsScheduleEntry>) -> Void) {
        completion(.init(entries: [.preview], policy: .never))
    }
}
