// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TMDBAPI",
    platforms: [
        .iOS("16.0")
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "TMDBAPI",
            targets: ["TMDBAPI"]),
    ],
    dependencies: [
        .package(path: "../Networking"),
        .package(path: "../Domain"),
        .package(url: "https://github.com/Quick/Quick.git", from: "7.6.2"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "13.7.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "TMDBAPI",
            dependencies: [
                "Networking",
                "Domain"
            ]
        ),
        .testTarget(
            name: "TMDBAPITests",
            dependencies: [
                "TMDBAPI",
                "Networking",
                "Domain",
                "Quick",
                "Nimble"
            ]
        )
    ]
)
