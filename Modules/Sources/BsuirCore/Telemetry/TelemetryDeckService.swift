import Foundation
import TelemetryClient

final class TelemetryDeckService {
    private let telemetryManager = TelemetryManager.self
}

// MARK: - TelemetryService

extension TelemetryDeckService: TelemetryService {
    func setup() {
        let configuration = TelemetryManagerConfiguration(appID: EnvVariables.generated.telemetryDeckAppId)
        telemetryManager.initialize(with: configuration)
    }

    func sendAppDidFinishLaunching() {
        telemetryManager.send("applicationDidFinishLaunching")
    }
}
