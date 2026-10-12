#!/bin/bash
# archive → ipa 書き出し → App Store Connect へアップロード → TestFlight の外部テスターグループへ配布
# までを手元(Xcode Cloud を使わず)で行うスクリプト。Makefile の testflight-* から呼ぶ。
#
# 使い方: Scripts/testflight.sh <command> <target>
#   command: archive | export | upload | distribute | all
#     archive     : Release で .xcarchive を作る
#     export      : .xcarchive から ipa を書き出す(手元に残す用。upload には不要)
#     upload      : .xcarchive を App Store Connect にアップロードする
#     distribute  : 処理完了を待って、輸出コンプライアンスを設定し、TestFlight グループに追加する
#     all         : archive → export → upload → distribute
#     testers     : テスターの一覧(GROUP を指定するとそのグループだけ)
#     tester-add  : EMAIL(カンマ区切り可)のテスターを GROUP に追加(外部なら招待メール送信)
#     tester-remove: EMAIL のテスターを GROUP から外す
#   target: slidys | flutter
#
# 認証は App Store Connect API キー。MyApps(Shireka 等)の deploy と同じ流儀で、秘密はリポジトリ外の
#   $ASC_HOME (既定 ~/.appstoreconnect)
#   ├── private_keys/AuthKey_<KEY_ID>.p8
#   └── slidys.env  (無ければ shireka.env を使う。同じチームのキーなので共用できる)
# に置き、env には ASC_KEY_ID / ASC_ISSUER_ID / ASC_TEAM_ID を定義する。スクリプトは中身を表示しない。
#   ASC_HOME / ASC_ENV_FILE で場所を上書きできる。
# 配布まわりの非秘密設定はリポジトリの .env(任意):
#   TESTFLIGHT_GROUPS: 追加するテスターグループ名(カンマ区切り)。既定は slidys=ExternalTestGroup / flutter=ExternalTester
#   TESTFLIGHT_NOTES : 「テスト内容」に入れる文言
#   BUILD_NUMBER     : CFBundleVersion。既定は日時(yyyyMMddHHmm)で毎回増える
#   MARKETING_VERSION: CFBundleShortVersionString。既定はプロジェクトの値
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# リポジトリの .env 読み込み(存在すれば)。TESTFLIGHT_GROUPS などの非秘密設定用
# 呼び出し側の環境変数(例: TESTFLIGHT_GROUPS=InternalTestGroup make ...)を優先し、
# .env は未設定の変数だけ埋める(KEY=VALUE 形式の単純な行のみ対応)。
if [ -f "$PROJECT_ROOT/.env" ]; then
    while IFS='=' read -r key value; do
        case "$key" in ''|\#*) continue ;; esac
        key="${key// /}"
        if [ -z "${!key+x}" ]; then
            export "$key=$value"
        fi
    done < "$PROJECT_ROOT/.env"
fi

COMMAND="${1:-all}"
TARGET="${2:-}"

usage() {
    echo "Usage: $0 [archive|export|upload|distribute|all|testers|tester-add|tester-remove] [slidys|flutter]" >&2
    exit 1
}

[ -n "$TARGET" ] || usage

TEAM_ID="669226BDWM"
case "$TARGET" in
    slidys)
        CONTAINER_FLAG="-project"
        CONTAINER="$PROJECT_ROOT/Apps/Slidys/Slidys.xcodeproj"
        SCHEME="Slidys"
        BUNDLE_ID="yugo.sugiyama.iOSDC2024Slide"
        EXTENSION_BUNDLE_ID="yugo.sugiyama.iOSDC2024Slide.SlidysBackgroundDownloadExtension"
        PROFILE_PREFIX="Slidys"
        DEFAULT_GROUPS="ExternalTestGroup"
        ;;
    flutter)
        # SlidysFlutter.xcworkspace(CocoaPods 生成)には Packages が入っていないので、
        # Packages・両アプリ・Pods をまとめた Apps/Slidys.xcworkspace でビルドする
        CONTAINER_FLAG="-workspace"
        CONTAINER="$PROJECT_ROOT/Apps/Slidys.xcworkspace"
        SCHEME="SlidysFlutter"
        BUNDLE_ID="yugo.sugiyama.iOSDC2024SlideFlutter"
        EXTENSION_BUNDLE_ID="yugo.sugiyama.iOSDC2024Slide.SlidysFlutterBackgroundDownloadExtension"
        PROFILE_PREFIX="SlidysFlutter"
        DEFAULT_GROUPS="ExternalTester"
        ;;
    *)
        echo "Unknown target: $TARGET" >&2; usage
        ;;
esac

# 追加先グループ。TESTFLIGHT_GROUPS(環境変数 / .env)が無ければアプリごとの既定を使う
TESTFLIGHT_GROUPS="${TESTFLIGHT_GROUPS:-$DEFAULT_GROUPS}"

# 出力先。build/ は .gitignore 対象。同じ target の最新成果物は build/testflight/<target>/latest から辿れる
OUT_ROOT="$PROJECT_ROOT/build/testflight/$TARGET"
LATEST_LINK="$OUT_ROOT/latest"
STAMP="${TESTFLIGHT_STAMP:-$(date +%Y%m%d%H%M)}"
OUT_DIR="$OUT_ROOT/$STAMP"
ARCHIVE_PATH="$OUT_DIR/$SCHEME.xcarchive"
EXPORT_DIR="$OUT_DIR/ipa"
BUILD_NUMBER="${BUILD_NUMBER:-$STAMP}"

# ---- 認証 ----
# upload / distribute は API キー必須。archive / export はキーが無ければ Xcode にログイン済みの
# アカウント(Xcode > Settings > Accounts)で署名する(手元で成果物だけ確認したいとき用)。
AUTH_ARGS=(-allowProvisioningUpdates)
ASC_HOME="${ASC_HOME:-$HOME/.appstoreconnect}"

# $ASC_HOME/slidys.env → 無ければ shireka.env の順で探す。見つかれば source して 0 を返す。
load_asc_env() {
    # 秘密が repo 内を指していないことを保証(意図しない commit / AI 読取を防ぐ)
    case "$(cd "$ASC_HOME" 2>/dev/null && pwd || echo "$ASC_HOME")" in
        "$PROJECT_ROOT"|"$PROJECT_ROOT"/*)
            echo "ASC_HOME ($ASC_HOME) がリポジトリ内を指しています。秘密ファイルはリポジトリ外に置いてください。" >&2
            exit 1
            ;;
    esac
    local candidates=("${ASC_ENV_FILE:-}" "$ASC_HOME/slidys.env" "$ASC_HOME/shireka.env")
    local f
    for f in "${candidates[@]}"; do
        [ -n "$f" ] && [ -f "$f" ] || continue
        set -a
        # shellcheck disable=SC1090
        . "$f"
        set +a
        ASC_ENV_FILE="$f"
        return 0
    done
    return 1
}

require_auth() {
    if ! load_asc_env; then
        cat >&2 <<MSG
認証 env ファイルが見つかりません: $ASC_HOME/slidys.env (または shireka.env)
以下の内容で作成してください(chmod 600):
  ASC_KEY_ID=XXXXXXXXXX
  ASC_ISSUER_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
  ASC_TEAM_ID=YYYYYYYYYY
p8 は $ASC_HOME/private_keys/AuthKey_<KEY_ID>.p8 に置く。
MSG
        exit 1
    fi
    : "${ASC_KEY_ID:?$ASC_ENV_FILE に ASC_KEY_ID を定義してください}"
    : "${ASC_ISSUER_ID:?$ASC_ENV_FILE に ASC_ISSUER_ID を定義してください}"
    ASC_KEY_PATH="$ASC_HOME/private_keys/AuthKey_${ASC_KEY_ID}.p8"
    [ -f "$ASC_KEY_PATH" ] || { echo "API key not found: $ASC_KEY_PATH" >&2; exit 1; }
    TEAM_ID="${ASC_TEAM_ID:-$TEAM_ID}"
    echo "auth: $ASC_ENV_FILE (key $ASC_KEY_ID)" >&2
    AUTH_ARGS=(
        -allowProvisioningUpdates
        -authenticationKeyPath "$ASC_KEY_PATH"
        -authenticationKeyID "$ASC_KEY_ID"
        -authenticationKeyIssuerID "$ASC_ISSUER_ID"
    )
}

optional_auth() {
    # SIGN_WITH_XCODE_ACCOUNT=1 なら API キーがあっても Xcode のアカウントで署名する。
    # API キーに Cloud Signing の権限が無く、そのアプリの App Store 用プロファイルがまだ無いときは
    # 一度これで export すると Xcode アカウント側でプロファイルが作られ、以後は API キーで通る。
    if [ "${SIGN_WITH_XCODE_ACCOUNT:-0}" = "1" ]; then
        echo "note: SIGN_WITH_XCODE_ACCOUNT=1 のため Xcode のアカウントで署名します" >&2
        return 0
    fi
    if load_asc_env && [ -n "${ASC_KEY_ID:-}" ] && [ -n "${ASC_ISSUER_ID:-}" ]; then
        require_auth
    else
        echo "note: $ASC_HOME に API キーの env が無いので、Xcode のアカウントで署名します" >&2
    fi
}

# ---- Flutter 前提チェック(SlidysFlutter は Flutter エンジンと Pods が必要) ----
check_flutter_prereqs() {
    [ "$TARGET" = "flutter" ] || return 0
    local xcconfig="$PROJECT_ROOT/flutter_slide/.ios/Flutter/Generated.xcconfig"
    local flutter_root
    flutter_root="$(grep '^FLUTTER_ROOT=' "$xcconfig" 2>/dev/null | cut -d= -f2- || true)"
    if [ -z "$flutter_root" ] || [ ! -x "$flutter_root/bin/flutter" ]; then
        cat >&2 <<MSG
Flutter SDK が見つかりません(FLUTTER_ROOT=$flutter_root)。
  1. fvm で flutter_slide が使うバージョンを入れる(fvm install / fvm use)
  2. cd flutter_slide && fvm flutter pub get && fvm flutter precache --ios
  3. cd Apps/SlidysFlutter && pod install
を済ませてから再実行してください。
MSG
        exit 1
    fi
    # iOS エンジン(Flutter.xcframework)は FLUTTER_ROOT のキャッシュから podhelper が参照する
    if [ ! -d "$flutter_root/bin/cache/artifacts/engine/ios-release/Flutter.xcframework" ]; then
        echo "Flutter engine が未取得です: cd flutter_slide && fvm flutter precache --ios" >&2
        exit 1
    fi
    if [ ! -f "$PROJECT_ROOT/Apps/SlidysFlutter/Pods/Manifest.lock" ]; then
        echo "Pods が未生成です: cd Apps/SlidysFlutter && pod install" >&2
        exit 1
    fi
    # Release では Flutter 側も release ビルドにする(Debug は JIT で実機起動できない)
    export FLUTTER_BUILD_MODE=release
}

# ---- App Store 用プロファイルを API で用意(API キーがあるときだけ) ----
# Xcode の Cloud Signing は API キーだと "Cloud signing permission error" になるため、
# Developer Portal API で作ったプロファイルを手元に入れて manual 署名で export する。
PROFILE_MAP_JSON=""
ensure_profiles() {
    [ -n "${ASC_KEY_PATH:-}" ] || return 0
    echo "==> Ensure App Store provisioning profiles ($PROFILE_PREFIX)"
    PROFILE_MAP_JSON="$(python3 "$SCRIPT_DIR/testflight_profiles.py" \
        --key-id "$ASC_KEY_ID" \
        --issuer-id "$ASC_ISSUER_ID" \
        --key-path "$ASC_KEY_PATH" \
        --bundle-ids "$BUNDLE_ID,$EXTENSION_BUNDLE_ID" \
        --name-prefix "$PROFILE_PREFIX")"
}

# ---- exportOptions.plist を生成 ----
write_export_options() {
    local path="$1" destination="$2"
    local signing_block
    if [ -n "$PROFILE_MAP_JSON" ]; then
        signing_block="$(python3 - "$PROFILE_MAP_JSON" <<'PY'
import json, sys
m = json.loads(sys.argv[1])
print("    <key>signingStyle</key>\n    <string>manual</string>")
print("    <key>signingCertificate</key>\n    <string>Apple Distribution</string>")
print("    <key>provisioningProfiles</key>\n    <dict>")
for k, v in m.items():
    print(f"        <key>{k}</key>\n        <string>{v}</string>")
print("    </dict>")
PY
)"
    else
        signing_block="    <key>signingStyle</key>
    <string>automatic</string>"
    fi
    cat > "$path" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store-connect</string>
    <key>destination</key>
    <string>$destination</string>
$signing_block
    <key>teamID</key>
    <string>$TEAM_ID</string>
    <key>uploadSymbols</key>
    <true/>
    <key>manageAppVersionAndBuildNumber</key>
    <false/>
</dict>
</plist>
PLIST
}

do_archive() {
    optional_auth
    check_flutter_prereqs
    mkdir -p "$OUT_DIR"
    ln -sfn "$OUT_DIR" "$LATEST_LINK"
    echo "==> Archive $SCHEME ($TARGET) build=$BUILD_NUMBER → $ARCHIVE_PATH"
    local version_args=(CURRENT_PROJECT_VERSION="$BUILD_NUMBER")
    if [ -n "${MARKETING_VERSION:-}" ]; then
        version_args+=(MARKETING_VERSION="$MARKETING_VERSION")
    fi
    xcodebuild archive \
        "$CONTAINER_FLAG" "$CONTAINER" \
        -scheme "$SCHEME" \
        -configuration Release \
        -destination 'generic/platform=iOS' \
        -archivePath "$ARCHIVE_PATH" \
        "${AUTH_ARGS[@]}" \
        "${version_args[@]}" \
        | tee "$OUT_DIR/archive.log" | grep -E "error:|warning: .*(sign|provision)|\*\* ARCHIVE" || true
    [ -d "$ARCHIVE_PATH" ] || { echo "Archive failed. See $OUT_DIR/archive.log" >&2; exit 1; }
    echo "$BUILD_NUMBER" > "$OUT_DIR/build_number"
}

resolve_archive() {
    # archive を飛ばして export/upload だけ呼ばれたときは latest を使う
    if [ ! -d "$ARCHIVE_PATH" ] && [ -L "$LATEST_LINK" ]; then
        OUT_DIR="$(readlink "$LATEST_LINK")"
        ARCHIVE_PATH="$OUT_DIR/$SCHEME.xcarchive"
        EXPORT_DIR="$OUT_DIR/ipa"
        [ -f "$OUT_DIR/build_number" ] && BUILD_NUMBER="$(cat "$OUT_DIR/build_number")"
    fi
    [ -d "$ARCHIVE_PATH" ] || { echo "No archive found. Run 'archive' first." >&2; exit 1; }
}

do_export() {
    optional_auth
    resolve_archive
    ensure_profiles
    echo "==> Export ipa → $EXPORT_DIR"
    write_export_options "$OUT_DIR/ExportOptions-export.plist" export
    xcodebuild -exportArchive \
        -archivePath "$ARCHIVE_PATH" \
        -exportPath "$EXPORT_DIR" \
        -exportOptionsPlist "$OUT_DIR/ExportOptions-export.plist" \
        "${AUTH_ARGS[@]}" \
        | tee "$OUT_DIR/export.log" | grep -E "error:|EXPORT" || true
    ls "$EXPORT_DIR"/*.ipa >/dev/null 2>&1 || { echo "Export failed. See $OUT_DIR/export.log" >&2; exit 1; }
    echo "ipa: $(ls "$EXPORT_DIR"/*.ipa)"
}

do_upload() {
    require_auth
    resolve_archive
    ensure_profiles
    echo "==> Upload to App Store Connect (build=$BUILD_NUMBER)"
    write_export_options "$OUT_DIR/ExportOptions-upload.plist" upload
    xcodebuild -exportArchive \
        -archivePath "$ARCHIVE_PATH" \
        -exportOptionsPlist "$OUT_DIR/ExportOptions-upload.plist" \
        "${AUTH_ARGS[@]}" \
        | tee "$OUT_DIR/upload.log" | grep -E "error:|Upload|EXPORT" || true
    grep -q "EXPORT SUCCEEDED" "$OUT_DIR/upload.log" || { echo "Upload failed. See $OUT_DIR/upload.log" >&2; exit 1; }
}

do_distribute() {
    require_auth
    resolve_archive
    local version
    version="$(/usr/libexec/PlistBuddy -c 'Print :ApplicationProperties:CFBundleShortVersionString' "$ARCHIVE_PATH/Info.plist")"
    echo "==> Distribute $BUNDLE_ID $version ($BUILD_NUMBER) to TestFlight groups: $TESTFLIGHT_GROUPS"
    python3 "$SCRIPT_DIR/testflight_distribute.py" \
        --key-id "$ASC_KEY_ID" \
        --issuer-id "$ASC_ISSUER_ID" \
        --key-path "$ASC_KEY_PATH" \
        --bundle-id "$BUNDLE_ID" \
        --version "$version" \
        --build-number "$BUILD_NUMBER" \
        --groups "$TESTFLIGHT_GROUPS" \
        ${TESTFLIGHT_NOTES:+--notes "$TESTFLIGHT_NOTES"}
}

run_testers() {
    require_auth
    local cmd="$1"
    python3 "$SCRIPT_DIR/testflight_testers.py" "$cmd" \
        --key-id "$ASC_KEY_ID" \
        --issuer-id "$ASC_ISSUER_ID" \
        --key-path "$ASC_KEY_PATH" \
        --bundle-id "$BUNDLE_ID" \
        ${GROUP:+--group "$GROUP"} \
        ${EMAIL:+--emails "$EMAIL"} \
        ${FIRST_NAME:+--first-name "$FIRST_NAME"} \
        ${LAST_NAME:+--last-name "$LAST_NAME"}
}

case "$COMMAND" in
    testers)       run_testers list ;;
    tester-add)    GROUP="${GROUP:-${TESTFLIGHT_GROUPS%%,*}}"; run_testers add ;;
    tester-remove) GROUP="${GROUP:-${TESTFLIGHT_GROUPS%%,*}}"; run_testers remove ;;
    archive)    do_archive ;;
    export)     do_export ;;
    upload)     do_upload ;;
    distribute) do_distribute ;;
    all)        do_archive && do_export && do_upload && do_distribute ;;
    *)          usage ;;
esac
