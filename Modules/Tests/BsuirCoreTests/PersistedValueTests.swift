import Foundation
import XCTest
@testable import BsuirCore

final class PersistedValueTests: XCTestCase {
    func testOnDidSet_isCalled_whenCalledOnOuterPersistedValue() {
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
        XCTAssertEqual(storedValue, 100)
        XCTAssertEqual(didSetCallCount, 1)
    }

    func testOnDidSet_isCalled_whenCalledOnInnerPersistedValue() {
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
        XCTAssertEqual(storedValue, 100)
        XCTAssertEqual(didSetCallCount, 1)
    }

    func testOnDidSet_isCalled_whenCalledOnFirstPersistedValueInLongChain() {
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
        XCTAssertEqual(storedValue, 100)
        XCTAssertEqual(didSetCallCount, 1)
    }

    func testOnDidSet_isCalledOnlyOnce_whenCalledOnLastPersistedValueInLongChain() {
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
        XCTAssertEqual(storedValue, 100)
        XCTAssertEqual(didSetCallCount, 1)
    }

    func testWithPublisher_emitsEvent_whenInnerPersistedValueChanges() {
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
        XCTAssertEqual(publisherValues, [-1, 100])
        cancellable.cancel()
    }

    func testSync_emitsDidSetEvent_whenInnerPersistedValueChanges() {
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
        XCTAssertEqual(storedValue, 100)
        XCTAssertEqual(didSetCallCount, 1)
    }

    func testSync_updatesBothStorages_whenSyncedValueIsSet() {
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
        XCTAssertEqual(cloudSyncService[cloudKey] as? Int, 100)
        XCTAssertEqual(storedValue, 100)
    }

    func testSync_readsCloudStorageFirst() {
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
        XCTAssertEqual(value, 100)
    }

    func testSync_readsInnerStorage_whenNoCloudValue() {
        // Given
        let cloudKey = "cloud-sync-value-key"
        var storedValue: Int? = 100
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
        XCTAssertEqual(value, 100)
    }

    func testSync_updatesInnerStorage_whenCloudValueIsUpdated() {
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
        XCTAssertEqual(storedValue, 100)
    }
}
