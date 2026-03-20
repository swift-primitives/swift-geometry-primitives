// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "insets-as-product",
    platforms: [.macOS(.v26)],
    targets: [
        .executableTarget(
            name: "insets-as-product"
        )
    ]
)
