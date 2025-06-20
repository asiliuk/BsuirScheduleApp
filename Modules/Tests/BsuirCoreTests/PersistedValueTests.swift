import Foundation
import Testing
@testable import BsuirCore

@Suite
struct PersistedValueTests {
    @Test
    func onDidSet_isCalled_whenCalledOnOuterPersistedValue() {
        // Given
        var didSetCallCount = 0
        var storedValue: Int?
        let innerPersistedValue = PersistedValue(
            get: { storedValue },
            set: { storedValue = $0 }
        )

        let outerPersistedValue = innerPersistedValue.onDidSet { didSetCallCount += 1 }

        // When
        outerPersistedValue.value = 100

        // Then
        #expect(storedValue == 100)
        #expect(didSetCallCount == 1)
    }

    @Test
    func onDidSet_isCalled_whenCalledOnInnerPersistedValue() {
        // Given
        var didSetCallCount = 0
        var storedValue: Int?
        let innerPersistedValue = PersistedValue(
            get: { storedValue },
            set: { storedValue = $0 }
        )

        _ = innerPersistedValue.onDidSet { didSetCallCount += 1 }

        // When
        innerPersistedValue.value = 100

        // Then
        #expect(storedValue == 100)
        #expect(didSetCallCount == 1)
    }

    @Test
    func onDidSet_isCalled_whenCalledOnFirstPersistedValueInLongChain() {
        // Given
        var didSetCallCount = 0
        var storedValue: Int?
        let innerPersistedValue = PersistedValue(
            get: { storedValue },
            set: { storedValue = $0 }
        )

        _ = innerPersistedValue
            .map(fromValue: { $0 }, toValue: { $0 })
            .map(fromValue: { $0 }, toValue: { $0 })
            .map(fromValue: { $0 }, toValue: { $0 })
            .map(fromValue: { $0 }, toValue: { $0 })
            .map(fromValue: { $0 }, toValue: { $0 })
            .map(fromValue: { $0 }, toValue: { $0 })
            .onDidSet { didSetCallCount += 1 }

        // When
        innerPersistedValue.value = 100

        // Then
        #expect(storedValue == 100)
        #expect(didSetCallCount == 1)
    }

    @Test
    func onDidSet_isCalledOnlyOnce_whenCalledOnLastPersistedValueInLongChain() {
        // Given
        var didSetCallCount = 0
        var storedValue: Int?
        let innerPersistedValue = PersistedValue(
            get: { storedValue },
            set: { storedValue = $0 }
        )

        let outerPersistedValue = innerPersistedValue
            .map(fromValue: { $0 }, toValue: { $0 })
            .map(fromValue: { $0 }, toValue: { $0 })
            .map(fromValue: { $0 }, toValue: { $0 })
            .map(fromValue: { $0 }, toValue: { $0 })
            .map(fromValue: { $0 }, toValue: { $0 })
            .map(fromValue: { $0 }, toValue: { $0 })
            .onDidSet { didSetCallCount += 1 }

        // When
        outerPersistedValue.value = 100

        // Then
        #expect(storedValue == 100)
        #expect(didSetCallCount == 1)
    }

    @Test
    func withPublisher_emitsEvent_whenInnerPersistedValueChanges() {
        // Given
        var storedValue: Int?
        let innerPersistedValue = PersistedValue(
            get: { storedValue },
            set: { storedValue = $0 }
        )

        let (_, publisher) = innerPersistedValue
            .unwrap(withDefault: -1)
            .withPublisher()

        var publisherValues: [Int] = []
        let cancellable = publisher.sink(receiveValue: { publisherValues.append($0) })

        // When
        innerPersistedValue.value = 100

        // Then
        #expect(publisherValues == [-1, 100])
        cancellable.cancel()
    }

    @Test
    func sync_emitsDidSetEvent_whenInnerPersistedValueChanges() {
        // Given
        var didSetCallCount = 0
        var storedValue: Int?
        let innerPersistedValue = PersistedValue(
            get: { storedValue },
            set: { storedValue = $0 }
        )

        _ = innerPersistedValue
            .sync(with: CloudSyncServiceMock(), forKey: "cloud-sync-value-key")
            .onDidSet { didSetCallCount += 1 }

        // When
        innerPersistedValue.value = 100

        // Then
        #expect(storedValue == 100)
        #expect(didSetCallCount == 1)
    }

    @Test
    func sync_updatesBothStorages_whenSyncedValueIsSet() {
        // Given
        let cloudKey = "cloud-sync-value-key"
        var storedValue: Int?
        let innerPersistedValue = PersistedValue(
            get: { storedValue },
            set: { storedValue = $0 }
        )

        let cloudSyncService = CloudSyncServiceMock()
        let syncedPersistedValue = innerPersistedValue
            .sync(with: cloudSyncService, forKey: cloudKey)

        // When
        syncedPersistedValue.value = 100

        // Then
        #expect(cloudSyncService[cloudKey] as? Int == 100)
        #expect(storedValue == 100)
    }

    @Test
    func sync_readsCloudStorageFirst() {
        // Given
        let cloudKey = "cloud-sync-value-key"
        var storedValue: Int?
        let innerPersistedValue = PersistedValue(
            get: { storedValue },
            set: { storedValue = $0 }
        )

        let cloudSyncService = CloudSyncServiceMock()
        let syncedPersistedValue = innerPersistedValue
            .sync(with: cloudSyncService, forKey: cloudKey)
        cloudSyncService[cloudKey] = 100

        // When
        let value = syncedPersistedValue.value

        // Then
        #expect(value == 100)
    }

    @Test
    func sync_doesNothing_whenNoValues() {
        // Given
        let cloudKey = "cloud-sync-value-key"
        var storedValue: Int?
        let innerPersistedValue = PersistedValue(
            get: { storedValue },
            set: { storedValue = $0 }
        )

        let cloudSyncService = CloudSyncServiceMock()
        let syncedPersistedValue = innerPersistedValue
            .sync(with: cloudSyncService, forKey: cloudKey)

        // When
        let value = syncedPersistedValue.value

        // Then
        #expect(value == nil)
        #expect(cloudSyncService.storage[cloudKey] == nil)
    }

    @Test
    func sync_readsInnerStorage_andUpdatesSyncService_whenNoCloudValue_andSyncInitialFlagTrue() {
        // Given
        let cloudKey = "cloud-sync-value-key"
        var storedValue: Int? = 100
        let innerPersistedValue = PersistedValue(
            get: { storedValue },
            set: { storedValue = $0 }
        )

        let cloudSyncService = CloudSyncServiceMock()
        let syncedPersistedValue = innerPersistedValue
            .sync(
                with: cloudSyncService,
                forKey: cloudKey,
                shouldSyncInitialLocalValue: true,
                userDefaults: .mock(suiteName: "sync test")
            )

        // When
        let value = syncedPersistedValue.value

        // Then
        #expect(value == 100)
        #expect(cloudSyncService.storage[cloudKey] as? Int == 100)
    }

    @Test
    func sync_uUpdatesSyncServiceOnce_whenNoCloudValue_andSyncInitialFlagTrue() {
        // Given
        let cloudKey = "cloud-sync-value-key"
        let userDefaults = UserDefaults.mock(suiteName: "sync test")
        var storedValue: Int? = 100
        let innerPersistedValue = PersistedValue(
            get: { storedValue },
            set: { storedValue = $0 }
        )

        let cloudSyncService = CloudSyncServiceMock()
        _ = innerPersistedValue
            .sync(
                with: cloudSyncService,
                forKey: cloudKey,
                shouldSyncInitialLocalValue: true,
                userDefaults: userDefaults
            )

        storedValue = 200
        cloudSyncService[cloudKey] = nil

        let syncedPersistedValue = innerPersistedValue
            .sync(
                with: cloudSyncService,
                forKey: cloudKey,
                shouldSyncInitialLocalValue: true,
                userDefaults: userDefaults
            )

        // When
        let value = syncedPersistedValue.value

        // Then
        #expect(value == 200)
        #expect(cloudSyncService.storage[cloudKey] == nil)
    }

    @Test
    func sync_readsInnerStorage_andDoesNotUpdateSyncService_whenNoCloudValue_andSyncInitialFlagFalse() {
        // Given
        let cloudKey = "cloud-sync-value-key"
        var storedValue: Int? = 100
        let innerPersistedValue = PersistedValue(
            get: { storedValue },
            set: { storedValue = $0 }
        )

        let cloudSyncService = CloudSyncServiceMock()
        let syncedPersistedValue = innerPersistedValue
            .sync(
                with: cloudSyncService,
                forKey: cloudKey,
                shouldSyncInitialLocalValue: false,
                userDefaults: .mock(suiteName: "sync test")
            )

        // When
        let value = syncedPersistedValue.value

        // Then
        #expect(value == 100)
        #expect(cloudSyncService.storage[cloudKey] == nil)
    }

    @Test
    func sync_updatesInnerStorage_whenCloudValueIsUpdated() {
        // Given
        let cloudKey = "cloud-sync-value-key"
        var storedValue: Int?
        let innerPersistedValue = PersistedValue(
            get: { storedValue },
            set: { storedValue = $0 }
        )

        let cloudSyncService = CloudSyncServiceMock()
        _ = innerPersistedValue
            .sync(with: cloudSyncService, forKey: cloudKey)

        // When
        cloudSyncService.observeChangesUpdates[0](100)

        // Then
        #expect(storedValue == 100)
    }
}
