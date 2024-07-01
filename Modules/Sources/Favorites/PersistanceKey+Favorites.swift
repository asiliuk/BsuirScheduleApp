import Foundation
import ComposableArchitecture
import BsuirCore

extension PersistenceReaderKey where Self == PersistenceKeyDefault<CloudSyncablePersistenceKey<Int>> {
    public static var freeLoveHighScore: Self {
        PersistenceKeyDefault(
            .cloudSyncable(
                key: "free-love-hich-score",
                cloudKey: "cloud-free-love-high-score",
                shouldSyncInitialLocalValue: true
            ),
            0
        )
    }
}

