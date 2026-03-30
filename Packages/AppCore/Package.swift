// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "AppCore",
    platforms: [
        .iOS(.v26),
        .macOS(.v15),
    ],
    products: [
        .library(
            name: "AppCore",
            targets: ["AppCore"]
        ),
    ],
    dependencies: [
        .package(path: "../iTunesAPI"),
        .package(path: "../Models"),
        .package(path: "../NetworkService"),
    ],
    targets: [
        .target(
            name: "AppCore",
            dependencies: [
                .product(name: "iTunesAPI", package: "iTunesAPI"),
                .product(name: "Models", package: "Models"),
            ]
        ),
        .testTarget(
            name: "AppCoreTests",
            dependencies: [
                "AppCore",
                .product(name: "NetworkServiceTestUtils", package: "NetworkService"),
            ]
        ),
    ]
)
