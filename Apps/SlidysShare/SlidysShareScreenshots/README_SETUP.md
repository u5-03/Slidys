# SlidysShareScreenshots - Manual Xcode Setup

This directory contains the source files for the `SlidysShareScreenshots` target. The target needs to be added to `SlidysShare.xcodeproj` manually in Xcode. All Swift source files, Info.plist, and the JSON config are already prepared here.

## Required Manual Steps in Xcode

### 1. Add new target

1. Open `Apps/SlidysShare/SlidysShare.xcodeproj` in Xcode.
2. File > New > Target... > Multiplatform > App.
3. Product Name: **SlidysShareScreenshots**
4. Team: same as SlidysShare
5. Organization Identifier: `yugo.sugiyama.SlidysShare`
6. Bundle Identifier will be: `yugo.sugiyama.SlidysShare.Screenshots`
7. Interface: SwiftUI, Language: Swift
8. Deployment targets: iOS 26, macOS 26, visionOS 26 (match main app).
9. Finish. Xcode will create a `SlidysShareScreenshots` group with a default `ContentView` and `SlidysShareScreenshotsApp`. **Delete those stub files** — we supply our own.

### 2. Add source files

Add the following files (already in `SlidysShareScreenshots/`) to the new target's Compile Sources:
- `ScreenshotApp.swift`
- `ScreenshotContentViews.swift`
- `ScreenshotSampleData.swift`
- `FakeSlideConnection.swift`

And add the JSON to **Copy Bundle Resources**:
- `slidys-share-screenshots.json`

Set `Info.plist` in the target build settings to point to `SlidysShareScreenshots/Info.plist` (or rely on Xcode-generated one and merge our keys).

### 3. Add production views as target members

In the File Inspector (right pane), for each of the following files, check the `SlidysShareScreenshots` target membership checkbox in addition to `SlidysShare`:
- `SlidysShare/Views/SlideBroadcastView.swift`
- `SlidysShare/Views/SlideReceiverView.swift`
- `SlidysShare/Views/SlideEditView.swift`
- `SlidysShare/Views/SlideListView.swift`
- `SlidysShare/Views/SlideDetailView.swift`
- `SlidysShare/Views/SlidePreviewView.swift`
- `SlidysShare/Views/ReactionOverlayView.swift`
- `SlidysShare/Views/ReactionPickerView.swift`
- `SlidysShare/Services/MultipeerManager.swift`
- `SlidysShare/Services/SlideStorage.swift`
- `SlidysShare/Services/MarkdownSlideParser.swift` (only if SlideListView transitively references it)
- `SlidysShare/Services/SlideDeck+Markdown.swift`
- `SlidysShare/Extensions/` (any extensions used by the above)

Note: These files reference `PreviewSampleData` inside `#if DEBUG` blocks. Ensure the screenshot target is **not** built with `DEBUG` active, OR also add `SlidysShare/PreviewHelpers.swift` to the screenshot target. Simpler: add `PreviewHelpers.swift` too.

### 4. Add Swift Package dependencies

Go to project settings > Package Dependencies, add a new local package:
- Click "+", then "Add Local..."
- Navigate to `/Users/yugo.sugiyama/Dev/Swift/AppStoreScreenshotTest/`
- Select the package.

Then on the `SlidysShareScreenshots` target's "Frameworks, Libraries, and Embedded Content":
- Add `AppStoreScreenshotTestCore`
- Add `SlidysShareCore` (already referenced by SlidysShare)
- Add `SlideKit` (already referenced via SlidysShareCore transitively, but may need explicit link)

### 5. Build settings for `SlidysShareScreenshots`

- `PRODUCT_BUNDLE_IDENTIFIER` = `yugo.sugiyama.SlidysShare.Screenshots`
- `SUPPORTED_PLATFORMS` = `iphoneos iphonesimulator macosx xros xrsimulator`
- `TARGETED_DEVICE_FAMILY` = `1,2,7` (iPhone, iPad, Vision Pro)
- `GENERATE_INFOPLIST_FILE` = `NO` (since we provide Info.plist)
- `INFOPLIST_FILE` = `SlidysShareScreenshots/Info.plist`

### 6. Verify build

```
xcodebuild -project SlidysShare.xcodeproj \
  -target SlidysShareScreenshots \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' build
```

### 7. Run screenshots

From `Apps/SlidysShare/`:
```
make screenshots-ios
make screenshots-ipados
make screenshots-macos
make screenshots-visionos
```

Output: `Apps/SlidysShare/screen_captures/ja/<DEVICE_TYPE>/*.png`
