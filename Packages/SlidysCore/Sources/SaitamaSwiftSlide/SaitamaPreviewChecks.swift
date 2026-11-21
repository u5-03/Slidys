import SwiftUI

#Preview("同一Window内の一覧プレビュー", traits: .fixedLayout(width: 1024, height: 768)) {
    SaitamaSwiftSlidePreviewView(onClose: {})
}

#Preview("会場カメラ・自動開始", traits: .fixedLayout(width: 1280, height: 720)) {
    SaitamaAudienceCameraSlide()
}
