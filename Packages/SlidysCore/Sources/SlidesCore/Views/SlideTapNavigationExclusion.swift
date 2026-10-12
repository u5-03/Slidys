//
//  SlideTapNavigationExclusion.swift
//  SlidesCore
//
//  スライド送り用の透明タップ領域(SlideBaseView の左上/右上の円)から、
//  スライド内の操作可能な領域(埋め込んだデモ画面など)をくり抜くための仕組み。
//  くり抜きたい View に `.excludesFromSlideTapNavigation()` を付けると、その領域は
//  タップしてもページ送りされず、中の View にタッチが届く。
//

import SwiftUI

/// タップ送りから除外する領域(スライド内 View の bounds)。SlideBaseView が集約して穴を開ける
public struct SlideTapNavigationExclusionKey: PreferenceKey {
    public static var defaultValue: [Anchor<CGRect>] { [] }
    public static func reduce(value: inout [Anchor<CGRect>], nextValue: () -> [Anchor<CGRect>]) {
        value.append(contentsOf: nextValue())
    }
}

public extension View {
    /// この View の領域では、スライド送りのタップ(左上・右上の透明領域)を無効にする。
    /// 埋め込んだデモ画面など、タップ操作するコンテンツに付ける。
    func excludesFromSlideTapNavigation() -> some View {
        anchorPreference(key: SlideTapNavigationExclusionKey.self, value: .bounds) { [$0] }
    }
}

/// 円から矩形の穴をくり抜いた形。`contentShape` で当たり判定に使う。
/// - Note: even-odd で矩形を重ねる方法だと、円の外側にはみ出た穴の部分が「塗り」になって
///   逆にタップを拾ってしまう(埋め込み View の下半分をタップすると別の円が反応する)ので、
///   Path の差集合で本当にくり抜く
struct HoledCircleShape: Shape {
    let holes: [CGRect]

    func path(in rect: CGRect) -> Path {
        var path = Path(ellipseIn: rect)
        for hole in holes where hole.intersects(rect) {
            path = path.subtracting(Path(hole))
        }
        return path
    }
}
