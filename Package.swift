// swift-tools-version: 6.3

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
        .package(path: "../swift-algebra-linear-primitives"),
        .package(path: "../swift-affine-primitives"),
        .package(path: "../swift-affine-geometry-primitives"),
        .package(path: "../swift-dimension-primitives"),
        .package(path: "../swift-formatting-primitives"),
        .package(path: "../swift-region-primitives"),
        .package(path: "../swift-numeric-primitives"),
    ],
    targets: [
        .target(
            name: "Geometry Primitives",
            dependencies: [
                .product(name: "Algebra Linear Primitives", package: "swift-algebra-linear-primitives"),
                .product(name: "Affine Primitives", package: "swift-affine-primitives"),
                .product(name: "Affine Geometry Primitives", package: "swift-affine-geometry-primitives"),
                .product(name: "Dimension Primitives", package: "swift-dimension-primitives"),
                .product(name: "Formatting Primitives", package: "swift-formatting-primitives"),
                .product(name: "Region Primitives", package: "swift-region-primitives"),
                .product(name: "Real Primitives", package: "swift-numeric-primitives"),
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
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
