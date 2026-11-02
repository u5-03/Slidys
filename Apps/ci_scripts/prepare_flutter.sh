#!/bin/sh
# Generate the local Swift package before Xcode resolves package dependencies.
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
REPOSITORY_DIR=$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)
MODULE_DIR="$REPOSITORY_DIR/flutter_slide"
FLUTTER_VERSION=$(python3 -c 'import json, sys; print(json.load(open(sys.argv[1]))["flutter"])' "$MODULE_DIR/.fvmrc")
FLUTTER_SDK_DIR=${FLUTTER_ROOT:-"$MODULE_DIR/.fvm/flutter_sdk"}

if [ ! -x "$FLUTTER_SDK_DIR/bin/flutter" ]; then
    if [ -e "$FLUTTER_SDK_DIR" ] || [ -L "$FLUTTER_SDK_DIR" ]; then
        echo "error: Invalid Flutter SDK at $FLUTTER_SDK_DIR" >&2
        exit 1
    fi
    mkdir -p "$(dirname "$FLUTTER_SDK_DIR")"
    git clone --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git "$FLUTTER_SDK_DIR"
fi

export FLUTTER_ROOT="$FLUTTER_SDK_DIR"
export PATH="$FLUTTER_ROOT/bin:$PATH"
export CI=true
export FLUTTER_SUPPRESS_ANALYTICS=true

# A fresh SDK bootstraps the Flutter tool before handling --version. Bootstrap
# logs can appear on stdout even with --machine, so never parse that stream.
# Flutter writes this version cache after initialization, before printing --version.
"$FLUTTER_ROOT/bin/flutter" --version
SDK_VERSION=$(python3 -c 'import json, sys; print(json.load(open(sys.argv[1]))["frameworkVersion"])' "$FLUTTER_ROOT/bin/cache/flutter.version.json")
if [ "$SDK_VERSION" != "$FLUTTER_VERSION" ]; then
    echo "error: Flutter $FLUTTER_VERSION is required by .fvmrc; found $SDK_VERSION at $FLUTTER_ROOT" >&2
    exit 1
fi

cd "$MODULE_DIR"
"$FLUTTER_ROOT/bin/flutter" precache --ios
"$FLUTTER_ROOT/bin/flutter" pub get --enforce-lockfile

# Flutter still generates a CocoaPods host for modules. Remove its Podfile
# after pub get, before swift-package decides whether to build CocoaPod plugins.
# Validate every native plugin first so unsupported plugins cannot be omitted.
python3 - <<'PY'
import json
from pathlib import Path

plugins = json.loads(Path('.flutter-plugins-dependencies').read_text())
unsupported = []
for plugin in plugins.get('plugins', {}).get('ios', []):
    if not plugin.get('native_build', True):
        continue
    platform = 'darwin' if plugin.get('shared_darwin_source') else 'ios'
    manifest = Path(plugin['path']) / platform / plugin['name'] / 'Package.swift'
    if not manifest.is_file():
        unsupported.append(plugin['name'])
if unsupported:
    raise SystemExit('error: iOS plugins must support SwiftPM: ' + ', '.join(unsupported))
PY

rm -f .ios/Podfile .ios/Podfile.lock

# Archive only needs device Release artifacts. Local development also prepares
# Debug, so switching between Run and Archive works without regenerating packages.
case "${CI_XCODEBUILD_ACTION:-}" in
    archive) BUILD_MODES=release ;;
    *) BUILD_MODES=debug,release ;;
esac
"$FLUTTER_ROOT/bin/flutter" build swift-package --platform ios --build-mode "$BUILD_MODES" --no-codesign
python3 "$SCRIPT_DIR/fix_video_player_spm.py" "$MODULE_DIR/build/ios/SwiftPackages"
