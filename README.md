# Slidys
This is presentaion slide app for some presentaions.

This application depends on [SlideKit](https://github.com/mtj0928/SlideKit) developed by [mtj0928](https://github.com/mtj0928).
So this slides contains a lot of animation expression using SwiftUI.

## Development Note
After changing app or package code, always run a visionOS build check before considering the work complete.

Example:
```sh
DEVELOPER_DIR="$(
  {
    selected="$(xcode-select -p 2>/dev/null)"
    if [[ "$selected" == *.app/Contents/Developer ]]; then
      printf '%s\n' "$selected"
    else
      ls -d /Applications/Xcode*.app/Contents/Developer 2>/dev/null | sort | tail -n 1
    fi
  }
)" \
xcodebuild -project Apps/Slidys/Slidys.xcodeproj \
  -scheme Slidys \
  -destination 'generic/platform=visionOS' \
  -derivedDataPath /tmp/SlidysDerivedData \
  build
```
