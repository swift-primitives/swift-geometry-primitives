// swift-tools-version: 6.3.3

import PackageDescription

let package = Package(
    name: "swift-geometry-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26)
    ],
    products: [
        .library(
            name: "Geometry Primitives",
            targets: ["Geometry Primitives"]
        ),
        .library(
            name: "Geometry Primitives Test Support",
            targets: ["Geometry Primitives Test Support"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-primitives/swift-linear-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-affine-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-affine-geometry-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-dimension-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-boundary-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-numeric-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-pair-primitives.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "Geometry Primitives",
            dependencies: [
                .product(name: "Linear Primitives", package: "swift-linear-primitives"),
                .product(name: "Affine Primitives", package: "swift-affine-primitives"),
                .product(name: "Affine Geometry Primitives", package: "swift-affine-geometry-primitives"),
                .product(name: "Dimension Primitives", package: "swift-dimension-primitives"),
                .product(name: "Boundary Primitives", package: "swift-boundary-primitives"),
                .product(name: "Real Primitives", package: "swift-numeric-primitives"),
                .product(name: "Pair Primitives", package: "swift-pair-primitives"),
            ]
        ),
        .target(
            name: "Geometry Primitives Test Support",
            dependencies: [
                "Geometry Primitives",
                .product(name: "Affine Primitives Test Support", package: "swift-affine-primitives"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Geometry Primitives Tests",
            dependencies: [
                "Geometry Primitives",
                "Geometry Primitives Test Support",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
