#!/bin/zsh
# スライドデッキの全ページを PNG 化し、一覧 HTML を生成する。
# 使い方: Tools/snapshot_slides.sh [deck] [outputDir]
#   deck: iosdc2026 (既定)  outputDir: 既定は ./build/slide-snapshots/<deck>
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
"$BIN" "$DECK" "$OUT"
echo "open: $OUT/index.html"
