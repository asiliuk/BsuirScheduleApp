import Foundation
import ComposableArchitecture
import BsuirCore
import ScheduleCore

// MARK: - High Score

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

// MARK: - Pinned

extension PersistenceReaderKey 
where Self == PersistenceKeyDefault<
    PersistenceKeyTransform<
        CloudSyncablePersistenceKey<[String: Any]>,
        CloudSyncableScheduleSource
    >
> {
    public static var pinnedSchedule: Self {
        let syncableDictionary = CloudSyncablePersistenceKey<[String: Any]>.cloudSyncable(
            key: "pinned-schedule",
            cloudKey: "cloud-pinned-schedule",
            shouldSyncInitialLocalValue: true,
            isEqual: { $0 as NSDictionary? == $1 as NSDictionary? }
        )

        let syncableCloudSource = PersistenceKeyTransform(
            base: syncableDictionary,
            coding: CloudSyncableScheduleSource.self
        )

        return PersistenceKeyDefault(syncableCloudSource, .nothing)
    }
}

// MARK: - Favorites

extension PersistenceReaderKey where Self == PersistenceKeyDefault<CloudSyncablePersistenceKey<[String]>> {
    public static var favoriteGroupNames: Self {
        PersistenceKeyDefault(
            .cloudSyncable(
                key: "favorite-group-names",
                cloudKey: "cloud-favorite-group-names",
                shouldSyncInitialLocalValue: true
            ),
            []
        )
    }
}

extension PersistenceReaderKey where Self == PersistenceKeyDefault<CloudSyncablePersistenceKey<[Int]>> {
    public static var favoriteLecturerIDs: Self {
        PersistenceKeyDefault(
            .cloudSyncable(
                key: "favorite-lector-ids",
                cloudKey: "cloud-favorite-lector-ids",
                shouldSyncInitialLocalValue: true
            ),
            []
        )
    }
}
