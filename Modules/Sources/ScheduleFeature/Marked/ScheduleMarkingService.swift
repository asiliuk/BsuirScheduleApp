import Foundation
import Combine
import Dependencies
import DependenciesMacros
import Favorites
import ScheduleCore
import BsuirCore

@DependencyClient
struct ScheduleMarkingService {
    // Favorite
    var isCurrentlyFavorite: (ScheduleSource) -> Bool = { _ in false }
    var isFavorite: (ScheduleSource) -> AnyPublisher<Bool, Never> = { _ in Just(false).eraseToAnyPublisher() }
    var favorite: (ScheduleSource) async -> Void
    var unfavorite: (ScheduleSource) async -> Void

    // Pinned
    var isCurrentlyPinned: (ScheduleSource) -> Bool = { _ in false }
    var isPinned: (ScheduleSource) -> AnyPublisher<Bool, Never> = { _ in Just(false).eraseToAnyPublisher() }
    var pin: (ScheduleSource) async -> Void
    var unpin: (ScheduleSource) async -> Void
}

// MARK: - Dependency

extension ScheduleMarkingService: DependencyKey {
    static let liveValue: ScheduleMarkingService = .live
}

extension DependencyValues {
    var scheduleMarkingService: ScheduleMarkingService {
        get { self[ScheduleMarkingService.self] }
        set { self[ScheduleMarkingService.self] = newValue }
    }
}

// MARK: - Live

private extension ScheduleMarkingService {
    static let live: ScheduleMarkingService = {
        @Dependency(\.favorites) var favorites
        @Dependency(\.pinnedScheduleService) var pinnedScheduleService
        @Dependency(\.reviewRequestService) var reviewRequestService
        return ScheduleMarkingService(
            isCurrentlyFavorite: { source in
                switch source {
                case let .group(name):
                    favorites.currentGroupNames.contains(name)
                case let .lector(lector):
                    favorites.currentLectorIds.contains(lector.id)
                }
            },
            isFavorite: { source in
                switch source {
                case let .group(name):
                    favorites.groupNames.map { $0.contains(name) }.removeDuplicates().eraseToAnyPublisher()
                case let .lector(lector):
                    favorites.lecturerIds.map { $0.contains(lector.id) }.removeDuplicates().eraseToAnyPublisher()
                }
            },
            favorite: { source in
                // Remove schedule from pinned if needed
                if pinnedScheduleService.currentSchedule() == source {
                    pinnedScheduleService.setCurrentSchedule(nil)
                }
                // Add schedule to favorites
                favorites.addToFavorites(source: source)

                // Log meaningful event
                await reviewRequestService.madeMeaningfulEvent(.addToFavorites)
            },
            unfavorite: { source in
                favorites.removeFromFavorites(source: source)
            },
            isCurrentlyPinned: { source in
                pinnedScheduleService.currentSchedule() == source
            },
            isPinned: { source in
                pinnedScheduleService.schedule().map({ $0 == source }).removeDuplicates().eraseToAnyPublisher()
            },
            pin: { source in
                // Move previously pinned schedule to favorites
                if let pinned = pinnedScheduleService.currentSchedule() {
                    favorites.addToFavorites(source: pinned)
                }
                // Remove newly pinned schedule from favorites
                favorites.removeFromFavorites(source: source)
                // Make new schedule as pinned
                pinnedScheduleService.setCurrentSchedule(source)

                // Log meaningful event
                await reviewRequestService.madeMeaningfulEvent(.pin)
            },
            unpin: { source in
                if pinnedScheduleService.currentSchedule() == source {
                    pinnedScheduleService.setCurrentSchedule(nil)
                }
            }
        )
    }()
}

// MARK: - MeaningfulEvent

private extension MeaningfulEvent {
    static let addToFavorites = Self(score: 5)
    static let pin = Self(score: 5)
}
