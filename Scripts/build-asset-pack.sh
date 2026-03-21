#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PACK_DIR="$PROJECT_ROOT/asset-packs/slidys-videos"
OUTPUT_FILE="$PROJECT_ROOT/slidys-videos.aar"

# .env 読み込み（存在すれば）
if [ -f "$PROJECT_ROOT/.env" ]; then
    set -a
    source "$PROJECT_ROOT/.env"
    set +a
fi

COMMAND="${1:-all}"
TARGET="${2:-both}"

resolve_apple_id() {
    local target="$1"
    case "$target" in
        slidys)
            echo "${SLIDYS_APPLE_ID:?Set SLIDYS_APPLE_ID in .env or environment}"
            ;;
        flutter)
            echo "${SLIDYS_FLUTTER_APPLE_ID:?Set SLIDYS_FLUTTER_APPLE_ID in .env or environment}"
            ;;
        *)
            echo "Unknown target: $target" >&2; exit 1
            ;;
    esac
}

build_pack() {
    echo "Building asset pack..."
    (cd "$PACK_DIR" && xcrun ba-package package manifest.json --output-path "$OUTPUT_FILE")
    echo "Built: $OUTPUT_FILE"
}

upload_pack_for() {
    local target="$1"
    local apple_id
    apple_id=$(resolve_apple_id "$target")

    : "${APPLE_ID:?Set APPLE_ID in .env or environment}"
    : "${APP_SPECIFIC_PASSWORD:?Set APP_SPECIFIC_PASSWORD in .env or environment}"

    [ -f "$OUTPUT_FILE" ] || { echo "Error: $OUTPUT_FILE not found. Run 'build' first." >&2; exit 1; }

    echo "Uploading to App Store Connect ($target, Apple ID: $apple_id)..."
    xcrun altool --upload-asset-pack "$OUTPUT_FILE" \
        --apple-id "$apple_id" \
        -u "$APPLE_ID" \
        -p "$APP_SPECIFIC_PASSWORD"
    echo "Upload complete ($target)."
}

upload_pack() {
    case "$TARGET" in
        slidys)  upload_pack_for slidys ;;
        flutter) upload_pack_for flutter ;;
        both)    upload_pack_for slidys && upload_pack_for flutter ;;
        *)       echo "Unknown target: $TARGET. Use: slidys|flutter|both" >&2; exit 1 ;;
    esac
}

case "$COMMAND" in
    build)  build_pack ;;
    upload) upload_pack ;;
    all)    build_pack && upload_pack ;;
    *)      echo "Usage: $0 [build|upload|all] [slidys|flutter|both]" >&2; exit 1 ;;
esac
