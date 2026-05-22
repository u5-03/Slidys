// swift-tools-version: 6.2
// visionOS 専用 遊戯王デュエルディスク体験パッケージ
//
// 本来は visionOS 26 だけでよいが、純粋なロジック層 (DuelSessionStore など) を
// macOS で `swift test` できるようにするため、プラットフォームに macOS を追加している。
// visionOS 専用 API を使う View / Scene 系ファイルは `#if os(visionOS)` でガード済み。
import PackageDescription

let package = Package(
    name: "YugiohDuelDiskPackage",
    platforms: [
        .visionOS(.v26),
        .macOS(.v26),
    ],
    products: [
        .library(name: "YugiohDuelDiskPackage", targets: ["YugiohDuelDiskPackage"]),
    ],
    dependencies: [
        // HandGesturePackage は visionOS 専用 API を使うため visionOS でだけリンクする。
        .package(path: "../HandGesturePackage"),
        // HandGestureKit はピンチ判定など軽量な手指距離 API を提供する。
        // macOS / iOS でも動作するライブラリだが、本パッケージでは visionOS でのみ使う。
        .package(path: "../HandGestureKit"),
        // Sugiy は visionOS / macOS / iOS / tvOS をサポート(モデル読込はテスト不要だが
        // パッケージ依存はすべてのプラットフォームで解決される)。
        .package(path: "../SlidysCore/Sources/SlidesCore/Assets/Sugiy"),
    ],
    targets: [
        .target(
            name: "YugiohDuelDiskPackage",
            dependencies: [
                .product(
                    name: "HandGesturePackage",
                    package: "HandGesturePackage",
                    condition: .when(platforms: [.visionOS])
                ),
                .product(
                    name: "HandGestureKit",
                    package: "HandGestureKit",
                    condition: .when(platforms: [.visionOS])
                ),
                .product(
                    name: "Sugiy",
                    package: "Sugiy",
                    condition: .when(platforms: [.visionOS])
                ),
            ]
        ),
        .testTarget(
            name: "YugiohDuelDiskPackageTests",
            dependencies: ["YugiohDuelDiskPackage"]
        ),
    ],
    swiftLanguageModes: [.v5]
)
