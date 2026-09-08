#!/bin/sh
# SlidysShare.xcodeproj の SlidysShareScreenshots(開発用ターゲット)は、
# リポジトリ外のローカルパッケージ ../../../AppStoreScreenshotTest を参照している。
# Xcode Cloud のチェックアウトにはこのディレクトリが存在せず、
# ワークスペース全体のパッケージ解決が失敗して配布ビルドが落ちる。
# 配布スキームではこのターゲットはビルド・リンクされないため、
# パッケージ解決だけが通る空のスタブを同じパスに生成する。
# (本物: https://github.com/u5-03/AppStoreScreenshotTest ※private)
set -eu

PACKAGE_DIR="$(dirname "${CI_PRIMARY_REPOSITORY_PATH:-/Volumes/workspace/repository}")/AppStoreScreenshotTest"

if [ -d "$PACKAGE_DIR" ]; then
    echo "AppStoreScreenshotTest already exists at $PACKAGE_DIR; skipping stub creation"
    exit 0
fi

mkdir -p "$PACKAGE_DIR/Sources/AppStoreScreenshotTestCore" "$PACKAGE_DIR/Sources/AppStoreScreenshotTest"

# NOTE: dependencies は本物の Package.swift と同一にすること。
# ワークスペースの Package.resolved はローカル(本物のパッケージ)で解決された内容なので、
# スタブの依存グラフがそれと食い違うと、Xcode が件数不一致の内部エラーでクラッシュする
# (-[NSMutableArray insertObjects:atIndexes:] count mismatch / FB16426594 系のバグ)。
cat > "$PACKAGE_DIR/Package.swift" <<'EOF'
// swift-tools-version: 6.2
// Xcode Cloud用のスタブ。実装は含まない(ci_post_clone.sh のコメント参照)。
import PackageDescription

let package = Package(
    name: "AppStoreScreenshotTest",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
        .visionOS(.v2)
    ],
    products: [
        .library(name: "AppStoreScreenshotTest", targets: ["AppStoreScreenshotTest"]),
        .library(name: "AppStoreScreenshotTestCore", targets: ["AppStoreScreenshotTestCore"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.18.0")
    ],
    targets: [
        .target(name: "AppStoreScreenshotTestCore"),
        .target(
            name: "AppStoreScreenshotTest",
            dependencies: [
                "AppStoreScreenshotTestCore",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ]
        )
    ]
)
EOF

echo "// Xcode Cloud stub" > "$PACKAGE_DIR/Sources/AppStoreScreenshotTestCore/Stub.swift"
echo "// Xcode Cloud stub" > "$PACKAGE_DIR/Sources/AppStoreScreenshotTest/Stub.swift"

echo "Created stub package at $PACKAGE_DIR"
