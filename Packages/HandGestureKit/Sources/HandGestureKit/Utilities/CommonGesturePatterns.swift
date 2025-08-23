//
//  CommonGesturePatterns.swift
//  HandGesturePackage
//
//  Created by Claude Code on 2025/07/24.
//

import Foundation

/// 頻繁に使用されるジェスチャーパターンのファクトリー
public enum CommonGesturePatterns {

    /// ピースサインのビルダーを作成
    public static func peaceSign() -> GestureBuilder {
        return GestureBuilder()
            .withStraightFingers(.index, .middle)
            .withBentFingers(.thumb, .ring, .little)
            .withFingerPointing(.index, direction: .top)
            .withFingerPointing(.middle, direction: .top)
            .withPalmFacing(.forward)
    }

    /// サムズアップのビルダーを作成
    public static func thumbsUp() -> GestureBuilder {
        return GestureBuilder()
            .withStraightFingers(.thumb)
            .withBentFingers(.index, .middle, .ring, .little)
            .withFingerPointing(.thumb, direction: .top)
    }

    /// 指差しのビルダーを作成
    public static func pointing() -> GestureBuilder {
        return GestureBuilder()
            .withStraightFingers(.index)
            .withBentFingers(.thumb, .middle, .ring, .little)
    }

    /// 握り拳のビルダーを作成
    public static func fist() -> GestureBuilder {
        return GestureBuilder()
            .withBentFingers(.thumb, .index, .middle, .ring, .little)
    }

    /// 開いた手(パー)のビルダーを作成
    public static func openHand() -> GestureBuilder {
        return GestureBuilder()
            .withStraightFingers(.thumb, .index, .middle, .ring, .little)
    }

    /// 握り拳＋特定の指を伸ばすパターン(手話Iなどで使用)
    public static func fistWithExtendedFinger(_ extendedFinger: FingerType) -> GestureBuilder {
        var bentFingers: [FingerType] = [.thumb, .index, .middle, .ring, .little]
        bentFingers.removeAll { $0 == extendedFinger }

        return GestureBuilder()
            .withStraightFingers(extendedFinger)
            .withBentFingers(bentFingers[0], bentFingers[1], bentFingers[2], bentFingers[3])
    }

    /// 複数の指を伸ばすパターン(手話W, Lなどで使用)
    public static func extendedFingers(_ fingers: FingerType...) -> GestureBuilder {
        let allFingers: [FingerType] = [.thumb, .index, .middle, .ring, .little]
        let bentFingers = allFingers.filter { !fingers.contains($0) }

        var builder = GestureBuilder()

        // 伸ばす指を設定
        for finger in fingers {
            builder = builder.withStraightFingers(finger)
        }

        // 曲げる指を設定
        for finger in bentFingers {
            builder = builder.withBentFingers(finger)
        }

        return builder
    }

    /// 平らな手(手話Bなどで使用)- 親指は手のひらに添える
    public static func flatHand() -> GestureBuilder {
        return GestureBuilder()
            .withStraightFingers(.index, .middle, .ring, .little)
            .withBentFingers(.thumb)
    }

    /// 水平方向の指差し(手話Gなどで使用)
    public static func horizontalPointing(_ pointingFinger: FingerType = .index) -> GestureBuilder {
        var bentFingers: [FingerType] = [.thumb, .index, .middle, .ring, .little]
        bentFingers.removeAll { $0 == pointingFinger }

        return GestureBuilder()
            .withStraightFingers(pointingFinger)
            .withBentFingers(bentFingers[0], bentFingers[1], bentFingers[2], bentFingers[3])
    }
}
