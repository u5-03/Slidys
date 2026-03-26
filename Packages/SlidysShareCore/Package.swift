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
        .package(url: "https://github.com/mtj0928/SlideKit", from: "0.7.0"),
        .package(url: "https://github.com/cybozu/LicenseList.git", from: "2.3.0"),
    ],
    targets: [
        .target(
            name: "SlidysShareCore",
            dependencies: [
                "SlideKit",
                "LicenseList",
            ]
        ),
    ],
    swiftLanguageModes: [.v5]
)
