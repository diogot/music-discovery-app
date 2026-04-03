// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "iTunesAPI",
    platforms: [
        .iOS(.v26),
        .macOS(.v15),
    ],
    products: [
        .library(
            name: "iTunesAPI",
            targets: ["iTunesAPI"]
        ),
    ],
    dependencies: [
        .package(path: "../NetworkService"),
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.58.0"),
    ],
    targets: [
        .target(
            name: "iTunesAPI",
            dependencies: [
                .product(name: "NetworkService", package: "NetworkService"),
            ],
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
        ),
        .testTarget(
            name: "iTunesAPITests",
            dependencies: [
                "iTunesAPI",
                .product(name: "NetworkServiceTestUtils", package: "NetworkService"),
            ],
            resources: [
                .copy("Fixtures"),
            ],
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
        ),
    ]
)
