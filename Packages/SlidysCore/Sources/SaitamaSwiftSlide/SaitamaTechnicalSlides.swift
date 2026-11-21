import SlideKit
import SlidesCore
import SwiftUI

/// Five minutes including a brief procedural-model demo. Details live in the companion blog.
@MainActor enum SaitamaTechnicalSlides {
    static var mesh: SaitamaCodeExplanationSlide {
        .init(title: "1. 頂点と三角形から、たい焼きを作る",
              points: ["輪郭と厚みに沿って頂点を並べる", "頂点を三角形でつなぎ、立体の表面に", "あんこは4つ、他の具材は1つずつ、生地などは9個のメッシュ"],
              code: """
              var mesh = MeshDescriptor()
              mesh.positions = .init(vertices)
              mesh.primitives = .triangles(indices)

              let resource = try MeshResource
                  .generate(from: [mesh])
              let model = ModelEntity(
                  mesh: resource,
                  materials: [material])
              """,
              script: "【35秒】輪郭に沿って頂点を並べ、前後に厚みを付け、三角形でつなぎます。法線とUVも設定し、MeshResourceに変換します。生成するのは16メッシュです。本体・尾びれ・背びれ・腹びれの4つ、断面の縁と内部の2つ、あんこの色別4つ、模様・目・焼印の3つで13。さらにクリーム・抹茶・チョコを1つずつ用意し、具材を切り替えて表示します。あんこでは13、ほかの具材では10メッシュが表示されます。")
    }
    static var texture: SaitamaCodeExplanationSlide {
        .init(title: "2. Swiftで焼き色と質感を作る",
              points: ["焼き色・ムラをピクセルごとに計算し画像に", "表面の向きを記録し、光の当たり方で凹凸感を出す", "画像のどの部分を、モデルのどこに貼るか決める"],
              code: """
              // ノイズ → ピクセル → CGImage
              // 画像からTextureResourceを生成
              var material =
                  PhysicallyBasedMaterial()
              material.baseColor = .init(
                  tint: .white,
                  texture: .init(color))
              material.normal = .init(
                  texture: .init(normal))
              """,
              script: "【35秒】形状とは別に表面の見た目を作ります。Swiftでピクセルごとにノイズを計算し、生地の焼き色やムラの画像を生成します。細かな凹凸感は、表面の向きを別の画像に記録して表現します。RealityKitがその向きと照明から明暗を計算するため、頂点を増やす必要はありません。2枚ともCGImageからTextureResourceに変換し、マテリアルに設定します。UV座標は、メッシュの各頂点に画像上の横と縦の位置を対応付ける座標です。色と向きの画像を表面のどこから読むかを決めます。PNG素材は使っていません。具材などは画像を使わず、色や粗さの数値だけで表現しています。")
    }
    static var anchors: SaitamaCodeExplanationSlide {
        .init(title: "3. 部位に、名前付きの目印を置く",
              points: ["部位を囲む箱の範囲からXYZを計算", "箱の、モデル正面側の面の中央に配置", "目印もrootの子として追加し、一緒に動かす"],
              code: """
              let partBounds = model.visualBounds(
                  relativeTo: root)
              let anchor = Entity()
              anchor.name = "Anchor_Eye"
              anchor.position = [
                  partBounds.center.x,
                  partBounds.center.y,
                  partBounds.max.z
              ]
              root.addChild(anchor)
              """,
              script: "【40秒】メッシュでも目印は置けます。生成した目などを囲む軸に沿った箱、バウンディングボックスをモデルの親座標で取得します。このモデルでは、回転前の正面をプラスZ方向として作っています。目印は箱の正面側の面の中央に置くので、XとYは箱の中心、Zは箱の最大値を指定します。回転するたびにカメラ側の端を探し直す処理ではありません。表面に接する点を厳密に検出する処理ではなく、部位の正面付近に置く簡易的な決め方です。目、尾びれ、背びれ、焼印の4か所です。アンカーという呼び方ですが、現実空間に固定するAnchorEntityではありません。名前付きの子Entityなので、たい焼きと一緒に回転・拡大します。部位を自動認識しているわけではなく、生成側が目印を決めています。")
    }
    static var buttons: SaitamaCodeExplanationSlide {
        .init(title: "4. 3で置いた目印に合わせて「＋」を表示",
              points: ["3で置いた空のEntityを目印として使う", "目印が画面のどこに見えるか計算", "その位置にSwiftUIの「＋」を表示"],
              code: """
              // 表示処理の概略
              if let projection =
                  projectedAnchor(part, in: size) {
                  Button("+") {
                      focus(on: part)
                  }
                  .position(projection.point)
              }
              """,
              script: "【50秒】ここでは3で追加した空のEntityを、そのまま位置の目印として使います。プラス自体はEntityの子ではなく、RealityViewに重ねるSwiftUIのボタンです。目印の3D上の位置を画面のXY座標へ変換し、そこを中心に表示します。モデルを回したら目印も一緒に動くので、プラスの表示位置も更新します。右のprojectedAnchorが目印の位置を画面座標に変換する関数で、表示処理だけを抜粋しています。")
    }
    static var focus: SaitamaCodeExplanationSlide {
        .init(title: "5. タップした部位へ、モデルごと寄せる",
              points: ["選んだ目印が左寄りに来る位置を計算", "拡大・回転・移動をTransformで指定", "move(to:)で0.7秒かけて滑らかに動かす", "カメラは固定。たい焼きを近づけ、向きを変える"],
              code: """
              let target = Transform(
                  scale: focusScale,
                  rotation: focusRotation,
                  translation: targetPosition
              )
              pivot.move(to: target,
                  relativeTo: nil,
                  duration: 0.7)
              """,
              script: "【55秒】タップしたらカメラではなく、たい焼き全体の親であるpivotを動かします。目印にフォーカス時の回転と拡大を掛け、デモ画面の左寄りに来るよう移動量を求めます。拡大、回転、移動をRealityKitのTransformで指定し、moveで0.7秒かけて滑らかに変化させます。補間とは、現在の状態と指定した状態の間をRealityKitが計算して動かすことです。撮影にたとえると、カメラを固定したまま、たい焼きを持って近づけ、向きを変えるイメージです。デモ画面の右側にはSwiftUIの解説パネルを表示します。スライドのコード欄を指すわけではありません。閉じると元のTransformへ戻します。")
    }
    static var cautions: SaitamaPointsSlide {
        .init(title: "6. 気をつけるべき点", points: [
            "アニメーション中にTransformを上書きしない",
            "目印とモデルの座標系・倍率をそろえる",
            "「＋」の位置計算はカメラ固定が前提。隠れた部位にも表示される場合がある"
        ], script: "【35秒】一番ハマるのは、RealityViewのupdateで回転を代入し、moveの途中経過を上書きしてしまうことです。遷移中は更新せず、終了時に最終Transformを確定します。また、生成モデルが既に持つ倍率を消さず、目印も同じ親座標で扱います。3Dの目印を画面上の位置へ変換する計算には、固定したカメラの位置と画角を使っています。カメラを動かす場合は、その計算にも反映が必要です。裏側の目印を非表示にする簡易判定はありますが、ひれなど他の部位に隠れているかまでは厳密に調べていないため、隠れた部位にもプラスが出る場合があります。")
    }
    static var summary: SaitamaPointsSlide {
        .init(title: "7. まとめ", points: [
            "Swiftで簡単な3Dオブジェクトを作るのはAIを活用すれば比較的簡単にできる",
            "今回紹介したモデルの見せ方はBlenderで作ったモデルでもほとんど同じ仕組みで実現可能です",
            "工夫次第で色々な活用余地がありそう！"
        ], script: "【30秒】Swiftで簡単な3Dオブジェクトを作るのはAIを活用すれば比較的簡単にできます。今回紹介したモデルの見せ方はBlenderで作ったモデルでもほとんど同じ仕組みで実現可能です。工夫次第で色々な活用余地がありそうです！")
    }
}

#Preview("技術概要：メッシュ") {
    SlidePreview { SaitamaTechnicalSlides.mesh }
        .slideTheme(CustomSlideTheme(showSlideIndex: false, listTextStyle: .large))
}
#Preview("技術概要：目印") {
    SlidePreview { SaitamaTechnicalSlides.anchors }
        .slideTheme(CustomSlideTheme(showSlideIndex: false, listTextStyle: .large))
}
#Preview("技術概要：フォーカス") {
    SlidePreview { SaitamaTechnicalSlides.focus }
        .slideTheme(CustomSlideTheme(showSlideIndex: false, listTextStyle: .large))
}

#Preview("技術概要：テクスチャ") {
    SlidePreview { SaitamaTechnicalSlides.texture }
        .slideTheme(CustomSlideTheme(showSlideIndex: false, listTextStyle: .large))
}

#Preview("技術概要：プラスボタン") {
    SlidePreview { SaitamaTechnicalSlides.buttons }
        .slideTheme(CustomSlideTheme(showSlideIndex: false, listTextStyle: .large))
}

#Preview("技術概要：注意点") {
    SlidePreview { SaitamaTechnicalSlides.cautions }
        .slideTheme(CustomSlideTheme(showSlideIndex: false, listTextStyle: .large))
}

#Preview("技術概要：まとめ") {
    SlidePreview { SaitamaTechnicalSlides.summary }
        .slideTheme(CustomSlideTheme(showSlideIndex: false, listTextStyle: .large))
}
