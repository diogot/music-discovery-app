// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "iTunesAPI",
    platforms: [
        .iOS(.v26),
    ],
    products: [
        .library(
            name: "iTunesAPI",
            targets: ["iTunesAPI"]
        ),
    ],
    dependencies: [
        .package(path: "../NetworkService"),
    ],
    targets: [
        .target(
            name: "iTunesAPI",
            dependencies: [
                .product(name: "NetworkService", package: "NetworkService"),
            ]
        ),
        .testTarget(
            name: "iTunesAPITests",
            dependencies: [
                "iTunesAPI",
                .product(name: "NetworkServiceTestUtils", package: "NetworkService"),
            ]
        ),
    ]
)
