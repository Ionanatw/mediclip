// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "CareDoc",
    platforms: [.iOS(.v17), .macOS(.v14)],
    targets: [
        .executableTarget(
            name: "CareDoc",
            path: "Sources/CareDoc"
        )
    ],
    swiftLanguageModes: [.v5]
)
