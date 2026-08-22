// swift-tools-version:6.2
// 召喚エフェクト(パーティクル)を Reality Composer Pro で編集・プレビューするためのアセットパッケージ。
// RCP で `SummonEffectAssets.rkassets/Scene.usda` を開くとパーティクルをプレビュー・調整できる。
// コードからは `summonEffectBundle` を使って `Entity(named: "Scene", in: summonEffectBundle)` で読み込む。

import PackageDescription

let package = Package(
    name: "SummonEffectAssets",
    platforms: [
        .visionOS(.v26),
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26)
    ],
    products: [
        .library(
            name: "SummonEffectAssets",
            targets: ["SummonEffectAssets"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SummonEffectAssets",
            dependencies: [],
            resources: [
                .process("SummonEffectAssets.rkassets")
            ]),
    ]
)
