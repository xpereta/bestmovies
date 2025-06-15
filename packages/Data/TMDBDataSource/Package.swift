// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TMDBDataSource",
    platforms: [
        .iOS("16.0")
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "TMDBDataSource",
            targets: ["TMDBDataSource"]),
    ],
    dependencies: [
        .package(path: "../Domain/BestMoviesDomain"),
        .package(path: "../Services/TMDBAPI"),
        .package(url: "https://github.com/Quick/Quick.git", from: "7.6.2"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "13.7.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "TMDBDataSource",
            dependencies: [
                "BestMoviesDomain",
                "TMDBAPI"
            ]
        ),
        .testTarget(
            name: "TMDBDataSourceTests",
            dependencies: [
                "TMDBDataSource",
                "BestMoviesDomain",
                "TMDBAPI",
                "Quick",
                "Nimble"
            ]
        )
    ]
)
