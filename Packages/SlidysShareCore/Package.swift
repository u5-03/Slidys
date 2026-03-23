// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "SlidysShareCore",
    platforms: [.iOS(.v26), .macOS(.v26), .visionOS(.v26)],
    products: [
        .library(
            name: "SlidysShareCore",
            targets: ["SlidysShareCore"]
        ),
    ],
    dependencies: [
        .package(path: "../SlidysCore"),
        .package(url: "https://github.com/mtj0928/SlideKit", from: "0.7.0"),
    ],
    targets: [
        .target(
            name: "SlidysShareCore",
            dependencies: [
                .product(name: "SlidesCore", package: "SlidysCore"),
                "SlideKit",
            ]
        ),
    ],
    swiftLanguageModes: [.v5]
)
