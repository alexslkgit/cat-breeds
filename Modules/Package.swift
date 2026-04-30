// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "Modules",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "Domain", type: .static, targets: ["Domain"]),
        .library(name: "Networking", type: .static, targets: ["Networking"]),
        .library(name: "Persistence", type: .static, targets: ["Persistence"]),
        .library(name: "BreedsListFeature", type: .static, targets: ["BreedsListFeature"]),
        .library(name: "BreedDetailFeature", type: .static, targets: ["BreedDetailFeature"]),
        .library(name: "FavouritesFeature", type: .static, targets: ["FavouritesFeature"]),
    ],
    targets: [
        .target(name: "Domain"),
        .target(name: "Networking", dependencies: ["Domain"]),
        .target(
            name: "Persistence",
            dependencies: ["Domain", "Networking"],
            swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]
        ),
        .target(name: "BreedsListFeature", dependencies: ["Domain"]),
        .target(name: "BreedDetailFeature", dependencies: ["Domain"]),
        .target(name: "FavouritesFeature", dependencies: ["Domain", "BreedsListFeature", "BreedDetailFeature"]),
        .testTarget(name: "DomainTests", dependencies: ["Domain"]),
        .testTarget(name: "NetworkingTests", dependencies: ["Networking"]),
        .testTarget(name: "PersistenceTests", dependencies: ["Persistence"]),
        .testTarget(name: "BreedsListFeatureTests", dependencies: ["BreedsListFeature"]),
        .testTarget(name: "BreedDetailFeatureTests", dependencies: ["BreedDetailFeature"]),
        .testTarget(name: "FavouritesFeatureTests", dependencies: ["FavouritesFeature"]),
    ]
)
