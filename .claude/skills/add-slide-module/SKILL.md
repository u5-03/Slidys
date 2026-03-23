# Add Slide Module Skill

Slidysプロジェクトに新しいカンファレンス用スライドモジュールを追加する。

## Overview

引数としてモジュール名（例: `TokyoSwiftSlide`）を受け取り、既存のスライドモジュールのパターンに従って新しいモジュールを作成する。

## Instructions

引数 `$ARGUMENTS` をモジュール名として使用する。

### Step 1: Package.swift の更新

`Packages/SlidysCore/Package.swift` に以下を追加:

1. **products** に `.library(name: "{ModuleName}", targets: ["{ModuleName}"])` を追加
2. **targets** に新しいターゲットを追加（依存関係は `SlidesCore` を最低限含める）
3. **SlidysCommon** ターゲットの dependencies に `"{ModuleName}"` を追加

### Step 2: ソースディレクトリの作成

`Packages/SlidysCore/Sources/{ModuleName}/` に以下のファイルを作成:

#### {ModuleName}.swift (メインビュー)

```swift
import SwiftUI
import SlideKit
import SlidesCore

public struct {ModuleName}View: SlideViewProtocol {
    let configuration = SlideConfiguration()

    public init() {}

    public var body: some View {
        SlideBaseView(slideConfiguration: configuration, showSlideIndex: false)
    }
}

struct SlideConfiguration: SlideConfigurationProtocol {
    @MainActor
    let slideIndexController = SlideIndexController() {
        TitleSlide()
        // Add more slides here
    }
}
```

#### Constants/Constants.swift

```swift
import SwiftUI

enum Constants {
    static let presentationName = "{DisplayName}"
}

extension Font {
    static let extraLargeFont: Font = .system(size: 140, weight: .bold)
    static let largeFont: Font = .system(size: 100, weight: .bold)
    static let midiumFont: Font = .system(size: 80, weight: .bold)
}

extension ShapeStyle where Self == Color {
    static var defaultForegroundColor: Color { return .init(hex: "DDDDDD") }
    static var slideBackgroundColor: Color { return .init(hex: "383944") }
    static var strokeColor: Color { return .init(hex: "F48F23") }
    static var themeColor: Color { return .init(hex: "2388F4") }
}
```

#### Slides/TitleSlide.swift

```swift
import SwiftUI
import SlideKit
import SlidesCore

@Slide
struct TitleSlide: View {
    public var transition: AnyTransition {
        SlideTransition.defaultTransition
    }

    private let title = "{PresentationTitle}"
    private let eventName = "{DisplayName}"

    var body: some View {
        VStack(spacing: 0) {
            Text(title)
                .font(.system(size: 140, weight: .heavy))
                .minimumScaleFactor(0.1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.themeColor)
            Spacer()
        }
        .frame(maxHeight: .infinity)
        .padding(80)
        .background(.slideBackgroundColor)
        .foregroundColor(.defaultForegroundColor)
    }

    var shouldHideIndex: Bool { true }
}

#Preview {
    SlidePreview {
        TitleSlide()
    }
}
```

### Step 3: SlidysCommon の更新

`Packages/SlidysCore/Sources/SlidysCommon/SlidysCommonView.swift` を更新:

1. `import {ModuleName}` を追加
2. `SlideType` enum に新しいケースを追加
3. `displayValue` に対応する文字列を追加
4. `view` に対応するビューを追加

### Step 4: Assets (任意)

必要に応じて `Packages/SlidysCore/Sources/{ModuleName}/Assets.xcassets/` を作成。

## Notes

- 既存のスライドモジュール（例: `HakodateSwiftSlide`）を参考にパターンを確認すること
- テーマカラーはユーザーに確認してから設定する
- SlideKitの `@Slide` マクロ、`CenterTextSlide`、`ViewSlide` などの既存コンポーネントを活用する
