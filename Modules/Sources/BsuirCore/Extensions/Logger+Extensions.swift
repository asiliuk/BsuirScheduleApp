import Foundation
import OSLog

extension Logger {
    public static let appState = bsuirSchedule(category: "AppState")

    public static func bsuirSchedule(category: String) -> Logger {
        Logger(subsystem: "com.asiliuk.BsuirScheduleApp", category: category)
    }
}
