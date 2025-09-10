// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MeBeatMeDeps",
    platforms: [
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "SharedKit",
            targets: ["SharedKit"]
        )
    ],
    targets: [
        .target(
            name: "SharedKit",
            dependencies: [],
            path: "src/iosMain/swift"
        )
    ]
)
