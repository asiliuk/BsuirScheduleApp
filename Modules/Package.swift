// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BsuirScheduleApp",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "AppFeature",
            targets: ["AppFeature"]),
        .library(
            name: "AboutFeature",
            targets: ["AboutFeature"]),
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
    ],
    dependencies: [
         .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.0.0"),
         .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "0.46.0"),
         .package(url: "https://github.com/pointfreeco/swift-url-routing.git", from: "0.4.0")
    ],
    targets: [
        // MARK: - Features
        .target(
            name: "AppFeature",
            dependencies: [
                "GroupsFeature", "LecturersFeature", "AboutFeature",
                "Deeplinking", "Favorites", "ComposableArchitectureUtils",
                "ScheduleCore", "BsuirApi", "BsuirUI",
                .tca
            ]
        ),
        .target(
            name: "AboutFeature",
            dependencies: ["ReachabilityFeature", "ScheduleCore", "BsuirUI", "ComposableArchitectureUtils", .tca, .tcaDependencies]
        ),
        .target(
            name: "GroupsFeature",
            dependencies: ["EntityScheduleFeature", "LoadableFeature", "Favorites", "BsuirApi", "ScheduleCore", "BsuirUI", "ComposableArchitectureUtils", .tca]
        ),
        .target(
            name: "LecturersFeature",
            dependencies: ["EntityScheduleFeature", "LoadableFeature", "Favorites", "ScheduleCore", "BsuirUI", "ComposableArchitectureUtils", .tca]
        ),
        .target(
            name: "EntityScheduleFeature",
            dependencies: ["ScheduleFeature", "LoadableFeature", "Favorites", "ScheduleCore", "BsuirUI", "ComposableArchitectureUtils", .tca]
        ),
        .target(
            name: "ScheduleFeature",
            dependencies: ["LoadableFeature", "Favorites", "ScheduleCore", "BsuirUI", "ComposableArchitectureUtils", .tca]
        ),
        .target(
            name: "LoadableFeature",
            dependencies: ["BsuirCore", "ComposableArchitectureUtils", .tca, .urlRouting]
        ),
        .target(
            name: "Favorites",
            dependencies: ["BsuirApi", .tcaDependencies]
        ),
        .target(
            name: "Deeplinking",
            dependencies: [.urlRouting, .tcaDependencies]
        ),
        .target(
            name: "ReachabilityFeature",
            dependencies: ["BsuirApi", .tca]
        ),
        // MARK: - Core
        .target(
            name: "ComposableArchitectureUtils",
            dependencies: [.tca]),
        .target(
            name: "BsuirUI",
            dependencies: ["BsuirApi", "ScheduleCore", "BsuirCore", "Kingfisher", .tcaDependencies]),
        .target(
            name: "ScheduleCore",
            dependencies: ["BsuirApi", .tcaDependencies]),
        .target(
            name: "BsuirApi",
            dependencies: ["BsuirCore", .urlRouting, .tcaDependencies]),
        .target(
            name: "BsuirCore",
            dependencies: [.tcaDependencies]),
        .testTarget(
            name: "ScheduleCoreTests",
            dependencies: ["ScheduleCore"]),
        .testTarget(
            name: "BsuirApiTests",
            dependencies: ["BsuirApi"],
            resources: [.process("jsons")]),
    ]
)

private extension Target.Dependency {
    static let urlRouting: Self = .product(name: "URLRouting", package: "swift-url-routing")
    static let tca: Self = .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
    static let tcaDependencies: Self = .product(name: "Dependencies", package: "swift-composable-architecture")
}
