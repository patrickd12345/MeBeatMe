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
        .binaryTarget(
            name: "SharedKit",
            path: "Frameworks/Shared.xcframework"
        )
    ]
)
