import Foundation
import TelemetryClient

final class TelemetryDeckService {
    private let telemetryManager: TelemetryManager.Type
    private let appId: String

    init(telemetryManager: TelemetryManager.Type = TelemetryManager.self, appId: String) {
        self.telemetryManager = telemetryManager
        self.appId = appId
    }
}

// MARK: - TelemetryService

extension TelemetryDeckService: TelemetryService {
    func setup() {
        let configuration = TelemetryManagerConfiguration(appID: appId)
        telemetryManager.initialize(with: configuration)
    }

    func sendAppDidFinishLaunching() {
        telemetryManager.send("applicationDidFinishLaunching")
    }
}
