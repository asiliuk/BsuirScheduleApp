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
}
