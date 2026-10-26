// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "PasteSaver",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "PasteSaver",
            path: "Sources/PasteSaver"
        )
    ]
)
