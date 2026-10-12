#!/bin/zsh
# スライドデッキの全ページを PNG 化し、一覧 HTML を生成する。
# 使い方: Tools/snapshot_slides.sh [deck] [outputDir] [language]
#   deck: iosdc2026 (既定)  outputDir: 既定は ./build/slide-snapshots/<deck>
#   language: ja (既定) | en  (多言語対応デッキの表示言語)
set -euo pipefail
DECK="${1:-iosdc2026}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${2:-$ROOT/build/slide-snapshots/$DECK}"
DERIVED="$ROOT/build/slide-snapshot-derived"
cd "$ROOT/Tools/SlideSnapshot"
xcodebuild -scheme SlideSnapshot -destination 'platform=macOS' -derivedDataPath "$DERIVED" build 2>&1 | grep -E "^\*\* BUILD|: error:" || true
BIN="$DERIVED/Build/Products/Debug/SlideSnapshot"
[ -x "$BIN" ] || { echo "binary not found: $BIN"; exit 1; }
rm -rf "$OUT"; mkdir -p "$OUT"
"$BIN" "$DECK" "$OUT" "${3:-ja}"
echo "open: $OUT/index.html"
