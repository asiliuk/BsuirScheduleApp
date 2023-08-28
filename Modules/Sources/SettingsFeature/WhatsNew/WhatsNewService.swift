import WhatsNewKit
import Dependencies

public protocol WhatsNewService {
    func whatsNew() -> WhatsNew?
    func markWhatsNewPresented(version: WhatsNew.Version)
}

// MARK: WhatsNewEnvironment

extension WhatsNewEnvironment: WhatsNewService {
    public func markWhatsNewPresented(version: WhatsNew.Version) {
        whatsNewVersionStore.save(presentedVersion: version)
    }
}

// MARK: - Dependency

extension DependencyValues {
    var whatsNewService: any WhatsNewService {
        get { self[WhatsNewServiceKey.self] }
        set { self[WhatsNewServiceKey.self] = newValue }
    }
}

private enum WhatsNewServiceKey: DependencyKey {
    static let liveValue: any WhatsNewService = WhatsNewEnvironment {
        WhatsNew.version300
    }
    static let previewValue: any WhatsNewService = WhatsNewServiceMock()
}

// MARK: - Mock

final class WhatsNewServiceMock: WhatsNewService {
    func whatsNew() -> WhatsNew? { nil }
    func markWhatsNewPresented(version: WhatsNew.Version) {}
}
