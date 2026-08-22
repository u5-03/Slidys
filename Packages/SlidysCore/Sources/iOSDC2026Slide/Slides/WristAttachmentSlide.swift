//
//  WristAttachmentSlide.swift
//  iOSDC2026Slide
//

import SlideKit
import SlidesCore
import SwiftUI

@Slide
struct WristAttachmentSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    var body: some View {
        HeaderSlide("デバイスを手首に「安定して」装着する") {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    Text("手首AnchorEntityに直接addChildすると、トラッキングロストの瞬間にデバイスが原点へ吹っ飛ぶ")
                        .font(.regularFont)
                    Text("手首は視野から外れやすく、ロストは日常的に発生する")
                        .font(.regularFont)

                    Text("対策: ワールド固定のルート配下に置き、ポーリングでローパス追従させる")
                        .font(.regularFont)
                        .padding(.top, 10)

                    CodeBlockView(
                        """
                        guard let wrist = leftWristAnchor, wrist.isAnchored else { return }
                        let wristTransform = Transform(matrix: wrist.transformMatrix(relativeTo: nil))
                        // 未トラッキング時に原点 (単位行列) が返るケースを弾く
                        guard simd_length(wristTransform.translation) > 0.05 else { return }
                        // ローパスで滑らかに追従 (60fps 想定で α=0.35)
                        let alpha: Float = 0.35
                        board.position = mix(board.position, targetPosition, t: alpha)
                        board.orientation = simd_slerp(board.orientation, targetRotation, alpha)
                        """)

                    Text("ロスト中は最後の姿勢を保持 + 補間でジッタを吸収 → 「腕に固定されている感」が出る")
                        .font(.regularFont)
                        .padding(.top, 10)
                }
            }
        }
    }
}

#Preview {
    SlidePreview {
        WristAttachmentSlide()
    }
    .headerSlideStyle(CustomHeaderSlideStyle())
    .itemStyle(CustomItemStyle())
}
