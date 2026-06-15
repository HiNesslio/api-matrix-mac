// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "API Matrix",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "API Matrix", targets: ["APIMatrix"])
    ],
    targets: [
        .executableTarget(
            name: "APIMatrix",
            path: "Sources/APIMatrix",
            resources: [.process("Resources")]
        )
    ]
)
