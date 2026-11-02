#!/usr/bin/env python3
"""アップロード済みビルドを TestFlight のテスターグループに配布する(App Store Connect API)。

Scripts/testflight.sh の distribute から呼ばれる。標準ライブラリと openssl コマンドだけで動く
(JWT の ES256 署名は openssl に任せる)。

流れ:
  1. bundle id からアプリを引く
  2. version / build number が一致するビルドが処理完了(VALID)になるまで待つ
  3. 輸出コンプライアンス(暗号化の申告)が未設定なら「非該当」にする ← 未設定だと配布できない
  4. 指定グループにビルドを追加する。外部グループが含まれていれば Beta App Review にも提出する
  5. (任意)「テスト内容」を設定する
"""
import argparse
import base64
import json
import subprocess
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

API = "https://api.appstoreconnect.apple.com"


def b64url(data: bytes) -> str:
    return base64.urlsafe_b64encode(data).rstrip(b"=").decode()


def der_to_raw_signature(der: bytes, size: int = 32) -> bytes:
    """openssl が出す DER 形式の ECDSA 署名を JWT 用の r||s 形式にする。"""
    assert der[0] == 0x30
    idx = 2
    assert der[idx] == 0x02
    r_len = der[idx + 1]
    r = der[idx + 2: idx + 2 + r_len]
    idx = idx + 2 + r_len
    assert der[idx] == 0x02
    s_len = der[idx + 1]
    s = der[idx + 2: idx + 2 + s_len]
    return r.lstrip(b"\x00").rjust(size, b"\x00") + s.lstrip(b"\x00").rjust(size, b"\x00")


def make_token(key_id: str, issuer_id: str, key_path: str) -> str:
    now = int(time.time())
    header = {"alg": "ES256", "kid": key_id, "typ": "JWT"}
    payload = {"iss": issuer_id, "iat": now, "exp": now + 20 * 60, "aud": "appstoreconnect-v1"}
    signing_input = f"{b64url(json.dumps(header, separators=(',', ':')).encode())}." \
                    f"{b64url(json.dumps(payload, separators=(',', ':')).encode())}"
    der = subprocess.run(
        ["openssl", "dgst", "-sha256", "-sign", key_path],
        input=signing_input.encode(), capture_output=True, check=True,
    ).stdout
    return f"{signing_input}.{b64url(der_to_raw_signature(der))}"


class Client:
    def __init__(self, key_id, issuer_id, key_path):
        self._args = (key_id, issuer_id, key_path)
        self._token = None
        self._token_at = 0

    def _auth(self):
        if self._token is None or time.time() - self._token_at > 15 * 60:
            self._token = make_token(*self._args)
            self._token_at = time.time()
        return {"Authorization": f"Bearer {self._token}"}

    def request(self, method, path, body=None, params=None):
        url = API + path
        if params:
            url += "?" + urllib.parse.urlencode(params)
        data = json.dumps(body).encode() if body is not None else None
        headers = self._auth()
        if data is not None:
            headers["Content-Type"] = "application/json"
        req = urllib.request.Request(url, data=data, method=method, headers=headers)
        try:
            with urllib.request.urlopen(req) as res:
                raw = res.read()
                return json.loads(raw) if raw else {}
        except urllib.error.HTTPError as e:
            detail = e.read().decode(errors="replace")
            raise RuntimeError(f"{method} {path} → HTTP {e.code}: {detail}") from None

    def get(self, path, **params):
        return self.request("GET", path, params=params)


def find_app(client, bundle_id):
    apps = client.get("/v1/apps", **{"filter[bundleId]": bundle_id}).get("data", [])
    if not apps:
        sys.exit(f"App not found for bundle id {bundle_id}")
    return apps[0]["id"]


def wait_for_build(client, app_id, version, build_number, timeout_sec):
    """アップロード直後は一覧に出るまで数分、処理完了まで更に数分かかるのでポーリングする。"""
    deadline = time.time() + timeout_sec
    while True:
        builds = client.get(
            "/v1/builds",
            **{
                "filter[app]": app_id,
                "filter[version]": build_number,
                "filter[preReleaseVersion.version]": version,
                "sort": "-uploadedDate",
                "limit": 1,
            },
        ).get("data", [])
        if builds:
            build = builds[0]
            state = build["attributes"]["processingState"]
            print(f"  build {build['id']} processingState={state}")
            if state == "VALID":
                return build
            if state in ("FAILED", "INVALID"):
                sys.exit(f"Build processing ended with {state}")
        else:
            print("  build not visible yet...")
        if time.time() > deadline:
            sys.exit("Timed out waiting for the build to finish processing")
        time.sleep(30)


def ensure_export_compliance(client, build):
    if build["attributes"].get("usesNonExemptEncryption") is None:
        print("  usesNonExemptEncryption is unset → set to false (HTTPS のみの標準的な暗号化)")
        client.request(
            "PATCH", f"/v1/builds/{build['id']}",
            {"data": {"type": "builds", "id": build["id"],
                      "attributes": {"usesNonExemptEncryption": False}}},
        )


def add_to_groups(client, app_id, build_id, group_names):
    groups = client.get("/v1/betaGroups", **{"filter[app]": app_id, "limit": 200}).get("data", [])
    by_name = {g["attributes"]["name"]: g for g in groups}
    has_external = False
    for name in group_names:
        group = by_name.get(name)
        if group is None:
            sys.exit(f"Beta group '{name}' not found. Existing: {sorted(by_name)}")
        kind = "internal" if group["attributes"].get("isInternalGroup") else "external"
        if group["attributes"].get("hasAccessToAllBuilds"):
            # 「すべてのビルドに自動でアクセス」設定のグループには処理完了時点で自動配布される。
            # 手で追加しようとすると 422 (INVALID_QC_STATE) になるので何もしない。
            print(f"  group '{name}' ({kind}) は全ビルド自動配布の設定なので、すでに配布済み")
        else:
            client.request(
                "POST", f"/v1/betaGroups/{group['id']}/relationships/builds",
                {"data": [{"type": "builds", "id": build_id}]},
            )
            print(f"  added to group '{name}' ({kind})")
        has_external |= kind == "external"
    return has_external


def submit_beta_review(client, build_id):
    # すでに提出済み(審査待ち / 審査中 / 承認済み)なら何もしない。
    # 過去バージョンで承認済みのアプリは、追加した時点で自動的に APPROVED になることがある。
    try:
        current = client.get(f"/v1/builds/{build_id}/betaAppReviewSubmission").get("data")
    except RuntimeError:
        current = None
    state = (current or {}).get("attributes", {}).get("betaReviewState")
    if state in ("WAITING_FOR_REVIEW", "IN_REVIEW", "APPROVED"):
        print(f"  Beta App Review: {state} (提出済みなのでスキップ)")
        return
    try:
        client.request(
            "POST", "/v1/betaAppReviewSubmissions",
            {"data": {"type": "betaAppReviewSubmissions",
                      "relationships": {"build": {"data": {"type": "builds", "id": build_id}}}}},
        )
        print("  submitted for Beta App Review (外部テスターへの配布に必要)")
    except RuntimeError as e:
        # 409: 提出済み / 422 INVALID_QC_STATE: すでに配布中で提出不要。どちらも続行する
        if "HTTP 409" in str(e) or "INVALID_QC_STATE" in str(e):
            print("  Beta App Review submission not needed (already submitted or distributing)")
        else:
            raise


def set_whats_new(client, build_id, notes, locale="ja"):
    existing = client.get(f"/v1/builds/{build_id}/betaBuildLocalizations").get("data", [])
    match = [loc for loc in existing if loc["attributes"].get("locale") == locale]
    if match:
        client.request(
            "PATCH", f"/v1/betaBuildLocalizations/{match[0]['id']}",
            {"data": {"type": "betaBuildLocalizations", "id": match[0]["id"],
                      "attributes": {"whatsNew": notes}}},
        )
    else:
        client.request(
            "POST", "/v1/betaBuildLocalizations",
            {"data": {"type": "betaBuildLocalizations",
                      "attributes": {"locale": locale, "whatsNew": notes},
                      "relationships": {"build": {"data": {"type": "builds", "id": build_id}}}}},
        )
    print(f"  whatsNew ({locale}) set")


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--key-id", required=True)
    parser.add_argument("--issuer-id", required=True)
    parser.add_argument("--key-path", required=True)
    parser.add_argument("--bundle-id", required=True)
    parser.add_argument("--version", required=True, help="CFBundleShortVersionString")
    parser.add_argument("--build-number", required=True, help="CFBundleVersion")
    parser.add_argument("--groups", default="ExternalTestGroup", help="カンマ区切りのテスターグループ名")
    parser.add_argument("--notes", default=None, help="「テスト内容」(whatsNew)")
    parser.add_argument("--timeout", type=int, default=45 * 60, help="処理完了を待つ秒数")
    args = parser.parse_args()

    client = Client(args.key_id, args.issuer_id, args.key_path)
    app_id = find_app(client, args.bundle_id)
    print(f"app id: {app_id}")
    print(f"waiting for build {args.version} ({args.build_number}) to be processed...")
    build = wait_for_build(client, app_id, args.version, args.build_number, args.timeout)
    ensure_export_compliance(client, build)
    if args.notes:
        set_whats_new(client, build["id"], args.notes)
    group_names = [g.strip() for g in args.groups.split(",") if g.strip()]
    has_external = add_to_groups(client, app_id, build["id"], group_names)
    if has_external:
        submit_beta_review(client, build["id"])
    print("done")


if __name__ == "__main__":
    main()
