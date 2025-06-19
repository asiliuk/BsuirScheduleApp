import Foundation
import ComposableArchitecture
import BsuirCore
import ScheduleCore

// MARK: - High Score

extension SharedReaderKey where Self == CloudSyncableSharedKey<Int>.Default {
    public static var freeLoveHighScore: Self {
        Self[
            .cloudSyncable(
                key: "free-love-hich-score",
                cloudKey: "cloud-free-love-high-score",
                shouldSyncInitialLocalValue: true
            ),
            default: 0
        ]
    }
}

// MARK: - Pinned

extension SharedReaderKey
where Self == CloudSyncableSharedKey<[String: Any]>.Map<CloudSyncableScheduleSource>.Default {
    public static var pinnedSchedule: Self {
        let syncableDictionary = CloudSyncableSharedKey<[String: Any]>.cloudSyncable(
            key: "pinned-schedule",
            cloudKey: "cloud-pinned-schedule",
            shouldSyncInitialLocalValue: true,
            isEqual: { $0 as NSDictionary? == $1 as NSDictionary? }
        )

        let syncableCloudSource = syncableDictionary.coding(CloudSyncableScheduleSource.self)

        return Self[syncableCloudSource, default: .nothing]
    }
}

// MARK: - Favorites

extension SharedReaderKey where Self == CloudSyncableSharedKey<[String]>.Default {
    public static var favoriteGroupNames: Self {
        Self[
            .cloudSyncable(
                key: "favorite-group-names",
                cloudKey: "cloud-favorite-group-names",
                shouldSyncInitialLocalValue: true
            ),
            default: []
        ]
    }
}

extension SharedReaderKey where Self == CloudSyncableSharedKey<[Int]>.Default {
    public static var favoriteLecturerIDs: Self {
        Self[
            .cloudSyncable(
                key: "favorite-lector-ids",
                cloudKey: "cloud-favorite-lector-ids",
                shouldSyncInitialLocalValue: true
            ),
            default: []
        ]
    }
}
