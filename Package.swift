// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "iOSUtils",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(name: "iOSUtils", targets: ["iOSUtils"])
    ],
    targets: [
        .target(
            name: "iOSUtils",
            path: "Sources/iOSUtils"
        ),
        .testTarget(
            name: "iOSUtilsTests",
            dependencies: ["iOSUtils"],
            path: "Tests/iOSUtilsTests"
        )
    ]
)
