// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Cocaine",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "Cocaine",
            path: "Cocaine",
            linkerSettings: [
                .unsafeFlags(["-framework", "Cocoa"]),
                .unsafeFlags(["-framework", "ServiceManagement"])
            ]
        )
    ]
)
