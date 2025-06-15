// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "BestMoviesDomain",
    platforms: [
        .iOS("16.0")
    ],
    products: [
        .library(
            name: "BestMoviesDomain",
            targets: ["BestMoviesDomain"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "BestMoviesDomain",
            dependencies: []),
        .testTarget(
            name: "BestMoviesDomainTests",
            dependencies: ["BestMoviesDomain"]),
    ]
)
