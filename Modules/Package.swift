// swift-tools-version:6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BsuirScheduleApp",
    defaultLocalization: "en",
    platforms: [.iOS(.v17)],
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
         .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.0.0"),
         .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.15.2"),
         .package(url: "https://github.com/pointfreeco/swift-url-routing.git", from: "0.6.0"),
         .package(url: "https://github.com/pointfreeco/swift-case-paths.git", from: "1.10.0"),
         .package(url: "https://github.com/apple/swift-collections.git", from: "1.0.0"),
         .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.1.0"),
         .package(url: "https://github.com/siteline/SwiftUI-Introspect.git", from: "26.0.0"),
         .package(url: "https://github.com/pointfreeco/swift-dependencies.git", from: "1.0.0"),
         .package(url: "https://github.com/simibac/ConfettiSwiftUI.git", from: "1.1.0"),
         .package(url: "https://github.com/ryanlintott/FrameUp.git", from: "0.5.0"),
         .package(url: "https://github.com/SvenTiigi/WhatsNewKit.git", from: "2.1.0"),
         .package(url: "https://github.com/EmergeTools/Pow", branch: "main"),
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
            ],
            swiftSettings: .bsuirDefaults,
        ),
        .target(
            name: "SettingsFeature",
            dependencies: ["PremiumClubFeature", "ReachabilityFeature", "ScheduleCore", "BsuirUI", .tca, .dependencies, .whatsNewKit],
            swiftSettings: .bsuirDefaults,
        ),
        .target(
            name: "PremiumClubFeature",
            dependencies: ["BsuirUI", "Favorites", "LoadableFeature", "AppIcons", .tca, .dependencies, .confetti, .pow],
            swiftSettings: .bsuirDefaults,
        ),
        .target(
            name: "GroupsFeature",
            dependencies: ["EntityScheduleFeature", "LoadableFeature", "Favorites", "BsuirApi", "ScheduleCore", "BsuirUI", "Deeplinking", .tca],
            swiftSettings: .bsuirDefaults,
        ),
        .target(
            name: "LecturersFeature",
            dependencies: ["EntityScheduleFeature", "LoadableFeature", "Favorites", "ScheduleCore", "BsuirUI", "Deeplinking", .tca],
            swiftSettings: .bsuirDefaults,
        ),
        .target(
            name: "EntityScheduleFeature",
            dependencies: ["ScheduleFeature", "LoadableFeature", "Favorites", "ScheduleCore", "BsuirUI", "Deeplinking", .tca],
            swiftSettings: .bsuirDefaults,
        ),
        .target(
            name: "ScheduleFeature",
            dependencies: ["LoadableFeature", "Favorites", "PremiumClubFeature", "ScheduleCore", "BsuirUI", "AppIcons", .tca, .swiftAlgorithms, .pow],
            swiftSettings: .bsuirDefaults,
        ),
        .target(
            name: "LoadableFeature",
            dependencies: ["BsuirCore", "BsuirUI", "ReachabilityFeature", .tca, .urlRouting],
            swiftSettings: .bsuirDefaults,
        ),
        .target(
            name: "Favorites",
            dependencies: ["BsuirCore", "ScheduleCore", .swiftCollections, .dependencies],
            swiftSettings: .bsuirDefaults,
        ),
        .target(
            name: "Deeplinking",
            dependencies: [.urlRouting, .dependencies],
            swiftSettings: .bsuirDefaults,
        ),
        .target(
            name: "ReachabilityFeature",
            dependencies: ["BsuirApi", .tca],
            swiftSettings: .bsuirDefaults,
        ),
        .target(
            name: "AppIcons",
            dependencies: ["BsuirCore", .dependencies, .casePaths],
            swiftSettings: .bsuirDefaults,
        ),
        // MARK: - Core
        .target(
            name: "BsuirUI",
            dependencies: ["BsuirApi", "ScheduleCore", "BsuirCore", "Kingfisher", .dependencies, .introspect, .frameUp, .tca],
            resources: [.process("Resources")],
            swiftSettings: .bsuirDefaults,
        ),
        .target(
            name: "ScheduleCore",
            dependencies: ["BsuirApi", .dependencies],
            swiftSettings: .bsuirDefaults,
        ),
        .target(
            name: "BsuirApi",
            dependencies: ["BsuirCore", .urlRouting, .dependencies],
            swiftSettings: .bsuirDefaults,
        ),
        .target(
            name: "BsuirCore",
            dependencies: [.dependencies, .swiftCollections, .tca],
            swiftSettings: .bsuirDefaults,
        ),
        .testTarget(
            name: "ScheduleCoreTests",
            dependencies: ["ScheduleCore"],
            swiftSettings: .bsuirDefaults,
        ),
        .testTarget(
            name: "BsuirCoreTests",
            dependencies: ["BsuirCore"],
            swiftSettings: .bsuirDefaults,
        ),
        .testTarget(
            name: "BsuirApiTests",
            dependencies: ["BsuirApi"],
            resources: [.process("jsons")],
            swiftSettings: .bsuirDefaults,
        ),
    ]
)

private extension Target.Dependency {
    static let urlRouting: Self = .product(name: "URLRouting", package: "swift-url-routing")
    static let tca: Self = .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
    static let dependencies: Self = .product(name: "Dependencies", package: "swift-dependencies")
    static let casePaths: Self = .product(name: "CasePaths", package: "swift-case-paths")
    static let swiftCollections: Self = .product(name: "Collections", package: "swift-collections")
    static let swiftAlgorithms: Self = .product(name: "Algorithms", package: "swift-algorithms")
    static let introspect: Self = .product(name: "SwiftUIIntrospect", package: "SwiftUI-Introspect")
    static let confetti: Self = .product(name: "ConfettiSwiftUI", package: "ConfettiSwiftUI")
    static let frameUp: Self = .product(name: "FrameUp", package: "FrameUp")
    static let whatsNewKit: Self = .product(name: "WhatsNewKit", package: "WhatsNewKit")
    static let pow: Self = .product(name: "Pow", package: "Pow")
}

private extension [PackageDescription.SwiftSetting] {
    static let bsuirDefaults: Self = [
        .swiftLanguageMode(.v5),
        .enableUpcomingFeature("InferSendableFromCaptures"),
    ]
}
