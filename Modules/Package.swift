// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BsuirScheduleApp",
    defaultLocalization: "en",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "AppFeature",
            targets: ["AppFeature"]),
        .library(
            name: "SettingsFeature",
            targets: ["SettingsFeature"]),
        .library(
            name: "PremiumClubFeature",
            targets: ["PremiumClubFeature"]),
        .library(
            name: "GroupsFeature",
            targets: ["GroupsFeature"]),
        .library(
            name: "LecturersFeature",
            targets: ["LecturersFeature"]),
        .library(
            name: "EntityScheduleFeature",
            targets: ["ScheduleFeature"]),
        .library(
            name: "ScheduleFeature",
            targets: ["ScheduleFeature"]),
        .library(
            name: "LoadableFeature",
            targets: ["LoadableFeature"]),
        .library(
            name: "BsuirUI",
            targets: ["BsuirUI"]),
        .library(
            name: "ScheduleCore",
            targets: ["ScheduleCore"]),
        .library(
            name: "BsuirApi",
            targets: ["BsuirApi"]),
        .library(
            name: "Deeplinking",
            targets: ["Deeplinking"]),
        .library(
            name: "Favorites",
            targets: ["Favorites"]),
    ],
    dependencies: [
         .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.9.0"),
         .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.0.0"),
         .package(url: "https://github.com/pointfreeco/swift-url-routing.git", from: "0.6.0"),
         .package(url: "https://github.com/apple/swift-collections.git", from: "1.0.0"),
         .package(url: "https://github.com/siteline/SwiftUI-Introspect.git", from: "0.10.0"),
         .package(url: "https://github.com/pointfreeco/swift-dependencies.git", from: "1.0.0"),
    ],
    targets: [
        // MARK: - Features
        .target(
            name: "AppFeature",
            dependencies: [
                "GroupsFeature", "LecturersFeature", "SettingsFeature",
                "Deeplinking", "Favorites",
                "ScheduleCore", "BsuirApi", "BsuirUI",
                .tca
            ]
        ),
        .target(
            name: "SettingsFeature",
            dependencies: ["PremiumClubFeature", "ReachabilityFeature", "ScheduleCore", "BsuirUI", .tca, .dependencies]
        ),
        .target(
            name: "PremiumClubFeature",
            dependencies: ["BsuirUI", "Favorites", .tca, .dependencies]
        ),
        .target(
            name: "GroupsFeature",
            dependencies: ["EntityScheduleFeature", "LoadableFeature", "Favorites", "BsuirApi", "ScheduleCore", "BsuirUI", .tca]
        ),
        .target(
            name: "LecturersFeature",
            dependencies: ["EntityScheduleFeature", "LoadableFeature", "Favorites", "ScheduleCore", "BsuirUI", .tca]
        ),
        .target(
            name: "EntityScheduleFeature",
            dependencies: ["ScheduleFeature", "LoadableFeature", "Favorites", "ScheduleCore", "BsuirUI", .tca]
        ),
        .target(
            name: "ScheduleFeature",
            dependencies: ["LoadableFeature", "Favorites", "PremiumClubFeature", "ScheduleCore", "BsuirUI", .tca]
        ),
        .target(
            name: "LoadableFeature",
            dependencies: ["BsuirCore", "BsuirUI", "ReachabilityFeature", .tca, .urlRouting]
        ),
        .target(
            name: "Favorites",
            dependencies: ["BsuirCore", "ScheduleCore", .swiftCollections, .dependencies]
        ),
        .target(
            name: "Deeplinking",
            dependencies: [.urlRouting, .dependencies]
        ),
        .target(
            name: "ReachabilityFeature",
            dependencies: ["BsuirApi", .tca]
        ),
        // MARK: - Core
        .target(
            name: "BsuirUI",
            dependencies: ["BsuirApi", "ScheduleCore", "BsuirCore", "Kingfisher", .dependencies, .introspect]),
        .target(
            name: "ScheduleCore",
            dependencies: ["BsuirApi", .dependencies]),
        .target(
            name: "BsuirApi",
            dependencies: ["BsuirCore", .urlRouting, .dependencies]),
        .target(
            name: "BsuirCore",
            dependencies: [.dependencies, .swiftCollections]),
        .testTarget(
            name: "ScheduleCoreTests",
            dependencies: ["ScheduleCore"]),
        .testTarget(
            name: "BsuirCoreTests",
            dependencies: ["BsuirCore"]),
        .testTarget(
            name: "BsuirApiTests",
            dependencies: ["BsuirApi"],
            resources: [.process("jsons")]),
    ]
)

private extension Target.Dependency {
    static let urlRouting: Self = .product(name: "URLRouting", package: "swift-url-routing")
    static let tca: Self = .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
    static let dependencies: Self = .product(name: "Dependencies", package: "swift-dependencies")
    static let swiftCollections: Self = .product(name: "Collections", package: "swift-collections")
    static let introspect: Self = .product(name: "SwiftUIIntrospect", package: "SwiftUI-Introspect")
}
