import WidgetKit
import SwiftUI

@main
struct ScheduleWidgetBundle: WidgetBundle {
    var body: some Widget {
        PinnedScheduleWidget()
        ExamsScheduleWidget()
    }
}
