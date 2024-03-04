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
        .library(
            name: "ScheduleFeature",
            targets: ["ScheduleFeature"]),
        .library(
            name: "SettingsFeature",
            targets: ["SettingsFeature"]),
    ],
    dependencies: [
         .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.9.0"),
         .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.7.0"),
         .package(url: "https://github.com/pointfreeco/swift-url-routing.git", from: "0.6.0"),
         .package(url: "https://github.com/apple/swift-collections.git", from: "1.0.0"),
         .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.1.0"),
         .package(url: "https://github.com/siteline/SwiftUI-Introspect.git", from: "0.10.0"),
         .package(url: "https://github.com/pointfreeco/swift-dependencies.git", from: "1.0.0"),
         .package(url: "https://github.com/simibac/ConfettiSwiftUI.git", from: "1.1.0"),
         .package(url: "https://github.com/ryanlintott/FrameUp.git", from: "0.5.0"),
         .package(url: "https://github.com/TelemetryDeck/SwiftClient.git", from: "1.4.0"),
         .package(url: "https://github.com/SvenTiigi/WhatsNewKit.git", from: "2.1.0"),
         .package(url: "https://github.com/AvdLee/Roadmap.git", branch: "main"),
         .package(url: "https://github.com/EmergeTools/Pow", from: "1.0.0"),
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
            dependencies: ["PremiumClubFeature", "ReachabilityFeature", "ScheduleCore", "BsuirUI", .tca, .dependencies, .whatsNewKit, .roadmap]
        ),
        .target(
            name: "PremiumClubFeature",
            dependencies: ["BsuirUI", "Favorites", "LoadableFeature", .tca, .dependencies, .confetti, .pow]
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
            dependencies: ["LoadableFeature", "Favorites", "PremiumClubFeature", "ScheduleCore", "BsuirUI", .tca, .swiftAlgorithms, .pow]
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
            dependencies: ["BsuirApi", "ScheduleCore", "BsuirCore", "Kingfisher", .dependencies, .introspect, .frameUp, .tca],
            resources: [.process("Resources")]
        ),
        .target(
            name: "ScheduleCore",
            dependencies: ["BsuirApi", .dependencies]),
        .target(
            name: "BsuirApi",
            dependencies: ["BsuirCore", .urlRouting, .dependencies]),
        .target(
            name: "BsuirCore",
            dependencies: [.dependencies, .swiftCollections, .telemetryClient]),
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
    static let swiftAlgorithms: Self = .product(name: "Algorithms", package: "swift-algorithms")
    static let introspect: Self = .product(name: "SwiftUIIntrospect", package: "SwiftUI-Introspect")
    static let confetti: Self = .product(name: "ConfettiSwiftUI", package: "ConfettiSwiftUI")
    static let frameUp: Self = .product(name: "FrameUp", package: "FrameUp")
    static let telemetryClient: Self = .product(name: "TelemetryClient", package: "SwiftClient")
    static let whatsNewKit: Self = .product(name: "WhatsNewKit", package: "WhatsNewKit")
    static let roadmap: Self = .product(name: "Roadmap", package: "Roadmap")
    static let pow: Self = .product(name: "Pow", package: "Pow")
}
