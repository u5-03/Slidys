//
//  CoordinateGotchaSlide.swift
//  iOSDC2026Slide
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct CoordinateGotchaSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("落とし穴: Z-up→Y-up変換がノードの向きに乗る") {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    Text("USDZルートにX軸-90°回転が付与され、全ノードのorientationに乗ってくる")
                        .font(.regularFont)
                    Text("→ ノードの向きをそのまま使うと、カードが盤面に垂直に突き刺さる😇")
                        .font(.regularFont)

                    Text("対策: ノードの+X軸を盤面のXZ平面へ射影して、ヨー回転だけを取り出す")
                        .font(.regularFont)
                        .padding(.top, 10)

                    CodeBlockView(
                        """
                        func yawOnlyOrientation(of node: Entity, relativeTo reference: Entity) -> simd_quatf {
                            let mappedX = node.convert(direction: SIMD3<Float>(1, 0, 0), to: reference)
                            let projected = SIMD3<Float>(mappedX.x, 0, mappedX.z)
                            let normalized = simd_normalize(projected)
                            // R_y(θ) は (1,0,0) を (cosθ, 0, -sinθ) へ写すので θ = atan2(-z, x)
                            let yaw = atan2(-normalized.z, normalized.x)
                            return simd_quatf(angle: yaw, axis: SIMD3<Float>(0, 1, 0))
                        }
                        """)

                    Text("教訓: DCCツール製モデルは「位置は信用してよいが、向きは座標系変換込み」と疑う")
                        .font(.regularFont)
                        .padding(.top, 10)
                }
            }
        }
    }
}

#Preview {
    SlidePreview {
        CoordinateGotchaSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
