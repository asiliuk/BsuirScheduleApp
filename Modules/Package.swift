// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BsuirScheduleApp",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "Features",
            targets: ["AboutFeature"]),
        .library(
            name: "BsuirUI",
            targets: ["BsuirUI"]),
        .library(
            name: "BsuirCore",
            targets: ["BsuirCore"]),
        .library(
            name: "BsuirApi",
            targets: ["BsuirApi"]),
    ],
    dependencies: [
         .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.0.0"),
         .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "0.43.0")
    ],
    targets: [
        .target(
            name: "AboutFeature",
            dependencies: ["BsuirCore", "BsuirUI", .tca, .dependencies]
        ),
        .target(
            name: "BsuirUI",
            dependencies: ["BsuirApi", "BsuirCore", "Kingfisher", .dependencies]),
        .target(
            name: "BsuirCore",
            dependencies: ["BsuirApi", .dependencies]),
        .target(
            name: "BsuirApi",
            dependencies: []),
        .testTarget(
            name: "BsuirCoreTests",
            dependencies: ["BsuirCore"]),
    ]
)

private extension Target.Dependency {
    static let tca: Self = .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
    static let dependencies: Self = .product(name: "Dependencies", package: "swift-composable-architecture")
}
