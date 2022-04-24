// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "API",
    platforms: [
        .macOS(.v12), .iOS(.v15), .tvOS(.v15), .watchOS(.v8)
    ],
    products: [
        .library(
            name: "API",
            targets: ["API"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "API",
            dependencies: []),
        .testTarget(
            name: "APITests",
            dependencies: ["API"]),
    ]
)
