// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MicSlop",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/soffes/HotKey", from: "0.2.1")
    ],
    targets: [
        .executableTarget(
            name: "MicSlop",
            dependencies: ["HotKey"]
        )
    ]
)
