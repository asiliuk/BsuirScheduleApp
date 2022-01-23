// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BsuirScheduleApp",
    platforms: [.iOS(.v15)],
    products: [
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
    ],
    targets: [
        .target(
            name: "BsuirUI",
            dependencies: ["BsuirApi", "BsuirCore", "Kingfisher"]),
        .target(
            name: "BsuirCore",
            dependencies: ["BsuirApi"]),
        .target(
            name: "BsuirApi",
            dependencies: []),
        .testTarget(
            name: "BsuirCoreTests",
            dependencies: ["BsuirCore"]),
    ]
)
