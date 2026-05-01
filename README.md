# Geometry Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Geometric primitives — composes affine, affine-geometry, algebra-linear, dimension, format, region, and numeric primitives. Ships an umbrella product plus a Test Support product for downstream test targets.

## Installation

Add the dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/swift-primitives/swift-geometry-primitives.git", from: "0.1.0")
]
```

Add the umbrella product to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "Geometry Primitives", package: "swift-geometry-primitives")
    ]
)
```

For test targets, additionally depend on `Geometry Primitives Test Support`:

```swift
.testTarget(
    name: "YourTargetTests",
    dependencies: [
        .product(name: "Geometry Primitives", package: "swift-geometry-primitives"),
        .product(name: "Geometry Primitives Test Support", package: "swift-geometry-primitives")
    ]
)
```

Requires Swift 6.2+.

## License

Apache 2.0. See [LICENSE](LICENSE).
