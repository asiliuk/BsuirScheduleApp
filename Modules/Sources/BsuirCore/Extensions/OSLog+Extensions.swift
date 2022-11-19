import Foundation
import os.log

extension OSLog {

    public static let appState = bsuirSchedule(category: "AppState")

    public static func bsuirSchedule(category: String) -> OSLog {
        OSLog(subsystem: "com.asiliuk.BsuirScheduleApp", category: category)
    }
}
