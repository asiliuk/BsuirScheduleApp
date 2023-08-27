import Foundation
import Dependencies

public protocol TelemetryService {
    func setup()
    func sendAppDidFinishLaunching()
}

// MARK: - Dependency

extension DependencyValues {
    public var telemetryService: any TelemetryService {
        get { self[TelemetryServiceKey.self] }
        set { self[TelemetryServiceKey.self] = newValue }
    }
}

private enum TelemetryServiceKey: DependencyKey {
    static let liveValue: any TelemetryService = {
        @Dependency(\.appConfiguration) var appConfiguration
        guard let appId = appConfiguration.telemetryDeckAppId else {
            assertionFailure("Failed to get telemetry app ID. Make sure it is setup correctly in .xcconfig files")
            return TelemetryServiceMock()
        }
        return TelemetryDeckService(appId: appId)
    }()

    static let previewValue: any TelemetryService = TelemetryServiceMock()
}

// MARK: - Mock

final class TelemetryServiceMock: TelemetryService {
    func setup() {}
    func sendAppDidFinishLaunching() {}
}
