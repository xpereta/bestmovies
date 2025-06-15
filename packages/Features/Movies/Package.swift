// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Movies",
    platforms: [
        .iOS("16.0")
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Movies",
            targets: ["Movies"]),
    ],
    dependencies: [
        .package(path: "../../Domain/BestMoviesDomain"),
        .package(path: "../CommonUI"),
        .package(url: "https://github.com/apple/swift-async-algorithms", from: "1.0.0"),
        .package(url: "https://github.com/Quick/Quick.git", from: "7.6.2"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "13.7.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Movies",
            dependencies: [
                "BestMoviesDomain",
                "CommonUI",
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms")
            ]
        ),
        .testTarget(
            name: "MoviesTests",
            dependencies: [
                "Movies",
                "BestMoviesDomain",
                "Quick",
                "Nimble"
            ]
        )
    ]
)
