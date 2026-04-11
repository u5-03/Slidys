#!/bin/bash
set -euo pipefail

# --- Resolve Xcode path ---
# Prefer Xcode.app over Command Line Tools; allow override via DEVELOPER_DIR env var.
if [ -z "${DEVELOPER_DIR:-}" ]; then
    XCODE_APP=$(mdfind "kMDItemCFBundleIdentifier == 'com.apple.dt.Xcode'" 2>/dev/null | head -1)
    if [ -n "$XCODE_APP" ]; then
        export DEVELOPER_DIR="$XCODE_APP/Contents/Developer"
    fi
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_DIR="$ROOT_DIR"
PROJECT="$PROJECT_DIR/SlidysShare.xcodeproj"
OUTPUT_DIR="$PROJECT_DIR/screen_captures"
BUILD_DIR="$PROJECT_DIR/build-screenshots"
BUNDLE_ID="yugo.sugiyama.SlidysShare.Screenshots"
APP_NAME="SlidysShareScreenshots"
# macOS window owner name differs from the target/executable name
MACOS_WINDOW_OWNER="SlidysShare"
JSON_PATH="$PROJECT_DIR/SlidysShareScreenshots/slidys-share-screenshots.json"
# ターゲット名でビルド（スキームではなくターゲット指定）

SCREENSHOT_NAMES=("CreateSlide" "PresentAnywhere" "LiveReactions" "MarkdownImport")
# Per-screenshot capture delay (seconds). LiveReactions needs shorter delay to catch mid-animation reactions.
SCREENSHOT_DELAYS=(3 3 1.5 3)
TOTAL_SCREENSHOTS=${#SCREENSHOT_NAMES[@]}
PLATFORM="${1:-all}"

# --- Logging helpers ---

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

log_step() {
    echo -e "${CYAN}[$(date +%H:%M:%S)]${RESET} $1"
}

log_success() {
    echo -e "${GREEN}  [OK]${RESET} $1"
}

log_error() {
    echo -e "${RED}  [ERROR]${RESET} $1" >&2
}

log_warn() {
    echo -e "${YELLOW}  [WARN]${RESET} $1"
}

log_progress() {
    local current="$1"
    local total="$2"
    local name="$3"
    echo -e "${CYAN}  [${current}/${total}]${RESET} Capturing ${name}..."
}

# --- Build ---

build_app() {
    local destination="$1"
    local platform_label="$2"
    local target="${3:-$APP_NAME}"
    log_step "Building ${target} for ${platform_label}..."

    local build_log="$BUILD_DIR/build.log"
    mkdir -p "$BUILD_DIR"

    if cd "$PROJECT_DIR" && xcodebuild build \
        -project SlidysShare.xcodeproj \
        -scheme "$target" \
        -destination "$destination" \
        -skipPackagePluginValidation \
        -skipMacroValidation \
        SYMROOT="$BUILD_DIR/Build/Products" \
        > "$build_log" 2>&1; then
        log_success "Build succeeded"
    else
        log_error "Build failed for ${platform_label}"
        echo ""
        echo "--- Build errors ---"
        if [ -f "$build_log" ]; then
            grep -E "error:" "$build_log" | head -10
            echo "--- Full log: $build_log ---"
        else
            echo "Build log not found. The build may have failed before starting."
        fi
        return 1
    fi
}

# --- Simulator UUID ---

get_device_uuid() {
    local device_name="$1"
    xcrun simctl list devices -j | swift -e '
import Foundation
let data = FileHandle.standardInput.readDataToEndOfFile()
let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
let devices = json["devices"] as! [String: [[String: Any]]]
for (_, deviceList) in devices {
    for d in deviceList {
        let name = d["name"] as? String ?? ""
        let state = d["state"] as? String ?? ""
        if name == CommandLine.arguments[1] && state == "Booted" {
            print(d["udid"] as! String)
            Foundation.exit(0)
        }
    }
}
for (_, deviceList) in devices {
    for d in deviceList {
        if (d["name"] as? String ?? "") == CommandLine.arguments[1] && (d["isAvailable"] as? Bool ?? false) {
            print(d["udid"] as! String)
            Foundation.exit(0)
        }
    }
}
' "$device_name"
}

# --- Language helpers ---

# Read languages from JSON config: "code|locale" per line
# If SCREENSHOT_LANG env var is set, only return that language.
get_languages() {
    if [ -n "${SCREENSHOT_LANG:-}" ]; then
        swift -e '
import Foundation
let data = try Data(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))
let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
let langs = json["languages"] as! [[String: Any]]
let target = CommandLine.arguments[2]
for l in langs { if (l["code"] as! String) == target { print("\(l["code"]!)|\(l["locale"]!)") } }
' "$JSON_PATH" "$SCREENSHOT_LANG"
    else
        swift -e '
import Foundation
let data = try Data(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))
let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
let langs = json["languages"] as! [[String: Any]]
for l in langs { print("\(l["code"]!)|\(l["locale"]!)") }
' "$JSON_PATH"
    fi
}

# --- Summary ---

print_summary() {
    local platform="$1"
    local output_path="$2"
    local count
    count=$(find "$output_path" -name '*.png' 2>/dev/null | wc -l | tr -d ' ')

    echo ""
    if [ "$count" -eq "$TOTAL_SCREENSHOTS" ]; then
        echo -e "${GREEN}${BOLD}${platform}: ${count}/${TOTAL_SCREENSHOTS} screenshots captured${RESET}"
    elif [ "$count" -gt 0 ]; then
        echo -e "${YELLOW}${BOLD}${platform}: ${count}/${TOTAL_SCREENSHOTS} screenshots captured (incomplete)${RESET}"
    else
        echo -e "${RED}${BOLD}${platform}: 0/${TOTAL_SCREENSHOTS} screenshots captured (failed)${RESET}"
    fi
    echo -e "  Output: ${output_path}"
}

# --- iOS ---

run_ios() {
    echo ""
    echo -e "${BOLD}=== iOS Screenshots ===${RESET}"
    local DEVICE_NAME="iPhone 17 Pro Max"
    local DESTINATION="platform=iOS Simulator,name=$DEVICE_NAME"
    local DEVICE_TYPE="APP_IPHONE_6_5"
    local OUTPUT_PATH="$OUTPUT_DIR/ja/$DEVICE_TYPE"

    build_app "$DESTINATION" "iOS" "$APP_NAME" || return 1

    local APP_PATH
    APP_PATH=$(find "$BUILD_DIR" -name "$APP_NAME.app" | head -1)
    if [ -z "$APP_PATH" ]; then
        log_error "Could not find built app for iOS simulator"
        return 1
    fi

    # Copy JSON config into app bundle
    cp "$JSON_PATH" "$APP_PATH/"
    log_success "JSON config bundled"

    log_step "Booting simulator: $DEVICE_NAME"
    xcrun simctl boot "$DEVICE_NAME" 2>/dev/null || true
    local DEVICE_UUID
    DEVICE_UUID=$(get_device_uuid "$DEVICE_NAME")
    log_success "Simulator ready (${DEVICE_UUID:0:8}...)"

    log_step "Installing app on simulator"
    xcrun simctl install "$DEVICE_UUID" "$APP_PATH"
    xcrun simctl status_bar "$DEVICE_UUID" override --time "9:41"
    log_success "App installed, status bar set to 9:41"

    local LANGUAGES
    LANGUAGES=$(get_languages)

    while IFS='|' read -r LANG_CODE LOCALE; do
        local LANG_OUTPUT_PATH="$OUTPUT_DIR/$LANG_CODE/$DEVICE_TYPE"
        mkdir -p "$LANG_OUTPUT_PATH"
        log_step "Capturing iOS screenshots ($LANG_CODE)..."

        for i in "${!SCREENSHOT_NAMES[@]}"; do
            local name="${SCREENSHOT_NAMES[$i]}"
            local prefix
            prefix=$(printf "%02d" $((i + 1)))
            log_progress "$((i + 1))" "$TOTAL_SCREENSHOTS" "$name ($LANG_CODE)"

            xcrun simctl terminate "$DEVICE_UUID" "$BUNDLE_ID" 2>/dev/null || true
            sleep 1

            SIMCTL_CHILD_SCREENSHOT_INDEX="$i" \
            SIMCTL_CHILD_SCREENSHOT_LANGUAGE="$LANG_CODE" \
                xcrun simctl launch "$DEVICE_UUID" "$BUNDLE_ID" \
                -AppleLanguages "($LANG_CODE)" -AppleLocale "$LOCALE" > /dev/null 2>&1

            sleep "${SCREENSHOT_DELAYS[$i]}"

            if xcrun simctl io "$DEVICE_UUID" screenshot "$LANG_OUTPUT_PATH/${prefix}_${name}.png" > /dev/null 2>&1; then
                sips -z 2778 1284 "$LANG_OUTPUT_PATH/${prefix}_${name}.png" > /dev/null 2>&1
                local actual_size
                actual_size=$(sips -g pixelWidth -g pixelHeight "$LANG_OUTPUT_PATH/${prefix}_${name}.png" 2>/dev/null | awk '/pixelWidth/{w=$2} /pixelHeight/{h=$2} END{print w"x"h}')
                log_success "${prefix}_${name}.png (${actual_size})"
            else
                log_error "Failed to capture ${name}"
            fi
        done

        print_summary "iOS ($LANG_CODE)" "$LANG_OUTPUT_PATH"
    done <<< "$LANGUAGES"

    xcrun simctl terminate "$DEVICE_UUID" "$BUNDLE_ID" 2>/dev/null || true
    xcrun simctl status_bar "$DEVICE_UUID" clear 2>/dev/null || true
}

# --- iPadOS ---

run_ipados() {
    echo ""
    echo -e "${BOLD}=== iPadOS Screenshots ===${RESET}"
    local DEVICE_NAME="iPad Pro 13-inch (M5)"
    local DESTINATION="platform=iOS Simulator,name=$DEVICE_NAME"
    local DEVICE_TYPE="APP_IPAD_PRO_3GEN_129"

    build_app "$DESTINATION" "iPadOS" "$APP_NAME" || return 1

    local APP_PATH
    APP_PATH=$(find "$BUILD_DIR" -name "$APP_NAME.app" | head -1)
    if [ -z "$APP_PATH" ]; then
        log_error "Could not find built app for iPadOS simulator"
        return 1
    fi

    cp "$JSON_PATH" "$APP_PATH/"
    log_success "JSON config bundled"

    log_step "Booting simulator: $DEVICE_NAME"
    xcrun simctl boot "$DEVICE_NAME" 2>/dev/null || true
    local DEVICE_UUID
    DEVICE_UUID=$(get_device_uuid "$DEVICE_NAME")
    log_success "Simulator ready (${DEVICE_UUID:0:8}...)"

    log_step "Installing app on simulator"
    xcrun simctl install "$DEVICE_UUID" "$APP_PATH"
    xcrun simctl status_bar "$DEVICE_UUID" override --time "9:41"
    log_success "App installed, status bar set to 9:41"

    local LANGUAGES
    LANGUAGES=$(get_languages)

    while IFS='|' read -r LANG_CODE LOCALE; do
        local LANG_OUTPUT_PATH="$OUTPUT_DIR/$LANG_CODE/$DEVICE_TYPE"
        mkdir -p "$LANG_OUTPUT_PATH"
        log_step "Capturing iPadOS screenshots ($LANG_CODE)..."

        for i in "${!SCREENSHOT_NAMES[@]}"; do
            local name="${SCREENSHOT_NAMES[$i]}"
            local prefix
            prefix=$(printf "%02d" $((i + 1)))
            log_progress "$((i + 1))" "$TOTAL_SCREENSHOTS" "$name ($LANG_CODE)"

            xcrun simctl terminate "$DEVICE_UUID" "$BUNDLE_ID" 2>/dev/null || true
            sleep 1

            SIMCTL_CHILD_SCREENSHOT_INDEX="$i" \
            SIMCTL_CHILD_SCREENSHOT_LANGUAGE="$LANG_CODE" \
                xcrun simctl launch "$DEVICE_UUID" "$BUNDLE_ID" \
                -AppleLanguages "($LANG_CODE)" -AppleLocale "$LOCALE" > /dev/null 2>&1

            sleep "${SCREENSHOT_DELAYS[$i]}"

            if xcrun simctl io "$DEVICE_UUID" screenshot "$LANG_OUTPUT_PATH/${prefix}_${name}.png" > /dev/null 2>&1; then
                local actual_size
                actual_size=$(sips -g pixelWidth -g pixelHeight "$LANG_OUTPUT_PATH/${prefix}_${name}.png" 2>/dev/null | awk '/pixelWidth/{w=$2} /pixelHeight/{h=$2} END{print w"x"h}')
                log_success "${prefix}_${name}.png (${actual_size})"
            else
                log_error "Failed to capture ${name}"
            fi
        done

        print_summary "iPadOS ($LANG_CODE)" "$LANG_OUTPUT_PATH"
    done <<< "$LANGUAGES"

    xcrun simctl terminate "$DEVICE_UUID" "$BUNDLE_ID" 2>/dev/null || true
    xcrun simctl status_bar "$DEVICE_UUID" clear 2>/dev/null || true
}

# --- macOS ---

run_macos() {
    echo ""
    echo -e "${BOLD}=== macOS Screenshots ===${RESET}"
    local DESTINATION="platform=macOS"
    local DEVICE_TYPE="APP_MACOS"

    build_app "$DESTINATION" "macOS" "$APP_NAME" || return 1

    local APP_PATH
    APP_PATH=$(find "$BUILD_DIR" -name "$APP_NAME.app" ! -path "*-iphonesimulator/*" ! -path "*-xrsimulator/*" | head -1)
    if [ -z "$APP_PATH" ]; then
        log_error "Could not find built app for macOS"
        return 1
    fi
    log_success "App found: $(basename "$APP_PATH")"

    mkdir -p "$APP_PATH/Contents/Resources"
    cp "$JSON_PATH" "$APP_PATH/Contents/Resources/"
    log_success "JSON config bundled"

    local CAPTURE_TOOL="$BUILD_DIR/capture_window"
    log_step "Compiling window capture tool..."
    if swiftc -O "$SCRIPT_DIR/capture_window.swift" -o "$CAPTURE_TOOL" 2>/dev/null; then
        log_success "Capture tool compiled"
    else
        log_error "Failed to compile capture tool"
        return 1
    fi

    local LANGUAGES
    LANGUAGES=$(get_languages)

    while IFS='|' read -r LANG_CODE LOCALE; do
        local LANG_OUTPUT_PATH="$OUTPUT_DIR/$LANG_CODE/$DEVICE_TYPE"
        mkdir -p "$LANG_OUTPUT_PATH"

        log_step "Capturing macOS screenshots ($LANG_CODE)..."

        for i in "${!SCREENSHOT_NAMES[@]}"; do
            local name="${SCREENSHOT_NAMES[$i]}"
            local prefix
            prefix=$(printf "%02d" $((i + 1)))
            log_progress "$((i + 1))" "$TOTAL_SCREENSHOTS" "$name ($LANG_CODE)"

            killall "$APP_NAME" 2>/dev/null || true
            killall "$MACOS_WINDOW_OWNER" 2>/dev/null || true
            sleep 2

            # Write config file (macOS open -a doesn't reliably relay env vars on relaunch)
            echo "{\"index\":$i,\"language\":\"$LANG_CODE\"}" > /tmp/slidysshare_screenshot_config.json

            open -a "$APP_PATH" \
                --env SCREENSHOT_INDEX="$i" \
                --env SCREENSHOT_LANGUAGE="$LANG_CODE" \
                --args -AppleLanguages "($LANG_CODE)" -AppleLocale "$LOCALE" 2>&1 || true

            sleep "${SCREENSHOT_DELAYS[$i]}"

            local capture_err
            if capture_err=$("$CAPTURE_TOOL" "$MACOS_WINDOW_OWNER" "$LANG_OUTPUT_PATH/${prefix}_${name}.png" 2>&1); then
                log_success "${prefix}_${name}.png"
            else
                log_error "Failed to capture ${name}: $capture_err"
                log_warn "Screen Recording permission may be required"
                log_warn "Grant: System Settings > Privacy & Security > Screen Recording > Terminal"
            fi
        done

        print_summary "macOS ($LANG_CODE)" "$LANG_OUTPUT_PATH"
    done <<< "$LANGUAGES"

    killall "$APP_NAME" 2>/dev/null || true
    killall "$MACOS_WINDOW_OWNER" 2>/dev/null || true
}

# --- visionOS ---

run_visionos() {
    echo ""
    echo -e "${BOLD}=== visionOS Screenshots ===${RESET}"
    local SIMULATOR_NAME="Apple Vision Pro"
    local DESTINATION="platform=visionOS Simulator,name=$SIMULATOR_NAME"
    local DEVICE_TYPE="APP_VISION_PRO"

    build_app "$DESTINATION" "visionOS" "$APP_NAME" || return 1

    local APP_PATH
    APP_PATH=$(find "$BUILD_DIR" -name "$APP_NAME.app" | head -1)
    if [ -z "$APP_PATH" ]; then
        log_error "Could not find built app for visionOS simulator"
        return 1
    fi

    cp "$JSON_PATH" "$APP_PATH/"
    log_success "JSON config bundled"

    local OVERLAY_TOOL="$BUILD_DIR/overlay_text"
    log_step "Compiling text overlay tool..."
    if swiftc -O "$SCRIPT_DIR/overlay_text.swift" -o "$OVERLAY_TOOL" 2>/dev/null; then
        log_success "Overlay tool compiled"
    else
        log_error "Failed to compile overlay tool"
        return 1
    fi

    log_step "Booting simulator: $SIMULATOR_NAME"
    xcrun simctl boot "$SIMULATOR_NAME" 2>/dev/null || true
    local DEVICE_UUID
    DEVICE_UUID=$(get_device_uuid "$SIMULATOR_NAME")
    log_success "Simulator ready (${DEVICE_UUID:0:8}...)"

    log_step "Installing app on simulator"
    xcrun simctl install "$DEVICE_UUID" "$APP_PATH"
    log_success "App installed"

    local LANGUAGES
    LANGUAGES=$(get_languages)

    while IFS='|' read -r LANG_CODE LOCALE; do
        local LANG_OUTPUT_PATH="$OUTPUT_DIR/$LANG_CODE/$DEVICE_TYPE"
        mkdir -p "$LANG_OUTPUT_PATH"
        log_step "Capturing visionOS screenshots ($LANG_CODE)..."

        # visionOS simulator needs extra time for app rendering
        # LiveReactions uses 2s to catch reactions mid-animation (opacity→0 at 2.5s)
        local VISIONOS_DELAYS=(5 5 2 5)

        for i in "${!SCREENSHOT_NAMES[@]}"; do
            local name="${SCREENSHOT_NAMES[$i]}"
            local prefix
            prefix=$(printf "%02d" $((i + 1)))
            log_progress "$((i + 1))" "$TOTAL_SCREENSHOTS" "$name ($LANG_CODE)"

            xcrun simctl terminate "$DEVICE_UUID" "$BUNDLE_ID" 2>/dev/null || true
            sleep 2

            SIMCTL_CHILD_SCREENSHOT_INDEX="$i" \
            SIMCTL_CHILD_SCREENSHOT_LANGUAGE="$LANG_CODE" \
                xcrun simctl launch "$DEVICE_UUID" "$BUNDLE_ID" \
                -AppleLanguages "($LANG_CODE)" -AppleLocale "$LOCALE" > /dev/null 2>&1

            sleep "${VISIONOS_DELAYS[$i]}"

            if xcrun simctl io "$DEVICE_UUID" screenshot "$LANG_OUTPUT_PATH/${prefix}_${name}.png" > /dev/null 2>&1; then
                log_success "${prefix}_${name}.png (captured)"

                # Overlay promotional text
                local headline_data
                headline_data=$(swift -e "
import Foundation
let data = try Data(contentsOf: URL(fileURLWithPath: \"$JSON_PATH\"))
let json = try JSONSerialization.jsonObject(with: data) as! [String:Any]
let screenshots = json[\"screenshots\"] as! [[String:Any]]
let headlines = screenshots[$i][\"headlines\"] as! [String:[String:Any]]
let h = headlines[\"$LANG_CODE\"]!
print(\"\(h[\"headline\"]!)|\(h[\"subheadline\"]!)\")
" 2>/dev/null) || true

                if [ -n "$headline_data" ]; then
                    local headline="${headline_data%%|*}"
                    local subheadline="${headline_data##*|}"
                    if "$OVERLAY_TOOL" "$LANG_OUTPUT_PATH/${prefix}_${name}.png" \
                                       "$LANG_OUTPUT_PATH/${prefix}_${name}.png" \
                                       "$headline" "$subheadline" 2>/dev/null; then
                        log_success "${prefix}_${name}.png (text overlaid)"
                        sips -z 2160 3840 "$LANG_OUTPUT_PATH/${prefix}_${name}.png" > /dev/null 2>&1
                        log_success "${prefix}_${name}.png (cropped & scaled)"
                    else
                        log_warn "Failed to overlay text on ${name}"
                    fi
                else
                    log_warn "Could not read headline for ${name}"
                fi
            else
                log_error "Failed to capture ${name}"
            fi
        done

        print_summary "visionOS ($LANG_CODE)" "$LANG_OUTPUT_PATH"
    done <<< "$LANGUAGES"

    xcrun simctl terminate "$DEVICE_UUID" "$BUNDLE_ID" 2>/dev/null || true
}

# --- Cleanup ---

cleanup() {
    rm -rf "$BUILD_DIR"
}
trap cleanup EXIT

# --- Main ---

case "$PLATFORM" in
    ios)      run_ios ;;
    ipados)   run_ipados ;;
    macos)    run_macos ;;
    visionos) run_visionos ;;
    all)
        PLATFORMS=("ios" "ipados" "macos" "visionos")
        FAILED=()
        for p in "${PLATFORMS[@]}"; do
            "run_$p" || FAILED+=("$p")
        done

        echo ""
        echo -e "${BOLD}==============================${RESET}"
        if [ ${#FAILED[@]} -eq 0 ]; then
            echo -e "${GREEN}${BOLD}All platforms completed successfully${RESET}"
        else
            echo -e "${YELLOW}${BOLD}Completed with errors: ${FAILED[*]}${RESET}"
        fi
        echo -e "${BOLD}==============================${RESET}"
        ;;
    *)
        echo "Usage: $0 [ios|ipados|macos|visionos|all]"
        exit 1
        ;;
esac
