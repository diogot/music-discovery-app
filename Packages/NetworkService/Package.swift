// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "NetworkService",
    platforms: [
        .iOS(.v26),
        .macOS(.v15),
    ],
    products: [
        .library(
            name: "NetworkService",
            targets: ["NetworkService"]
        ),
        .library(
            name: "NetworkServiceTestUtils",
            targets: ["TestUtils"]
        ),
    ],
    targets: [
        .target(
            name: "NetworkService"
        ),
        .target(
            name: "TestUtils",
            dependencies: ["NetworkService"]
        ),
        .testTarget(
            name: "NetworkServiceTests",
            dependencies: ["NetworkService", "TestUtils"]
        ),
    ]
)
