// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-geometry-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(
            name: "Geometry Primitives",
            targets: ["Geometry Primitives"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-primitives/swift-algebra-primitives.git", from: "0.0.1"),
        .package(url: "https://github.com/swift-primitives/swift-algebra-linear-primitives.git", from: "0.0.1"),
        .package(url: "https://github.com/swift-primitives/swift-affine-primitives.git", from: "0.0.1"),
        .package(url: "https://github.com/swift-primitives/swift-dimension-primitives.git", from: "0.0.1"),
        .package(url: "https://github.com/swift-primitives/swift-formatting-primitives.git", from: "0.0.1"),
        .package(url: "https://github.com/swift-primitives/swift-region-primitives.git", from: "0.0.1"),
        .package(url: "https://github.com/swift-primitives/swift-symmetry-primitives.git", from: "0.0.1"),
        .package(url: "https://github.com/swift-primitives/swift-numeric-primitives.git", from: "0.0.1"),
        .package(url: "https://github.com/swift-primitives/swift-test-primitives.git", from: "0.0.1"),
    ],
    targets: [
        .target(
            name: "Geometry Primitives",
            dependencies: [
                .product(name: "Algebra Primitives", package: "swift-algebra-primitives"),
                .product(name: "Algebra Linear Primitives", package: "swift-algebra-linear-primitives"),
                .product(name: "Affine Primitives", package: "swift-affine-primitives"),
                .product(name: "Dimension Primitives", package: "swift-dimension-primitives"),
                .product(name: "Formatting Primitives", package: "swift-formatting-primitives"),
                .product(name: "Region Primitives", package: "swift-region-primitives"),
                .product(name: "Real Primitives", package: "swift-numeric-primitives"),
            ]
        ),
        .testTarget(
            name: "Geometry Primitives Tests",
            dependencies: [
                "Geometry Primitives",
                .product(name: "Symmetry Primitives", package: "swift-symmetry-primitives"),
                .product(name: "Test Primitives", package: "swift-test-primitives"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    let settings: [SwiftSetting] = [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
    ]
    target.swiftSettings = (target.swiftSettings ?? []) + settings
}
