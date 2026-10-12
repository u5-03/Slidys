#!/usr/bin/env python3
"""App Store 配布用のプロビジョニングプロファイルを API で用意し、手元にインストールする。

Xcode の Cloud Signing は API キーだと権限エラーになることがあるため、Developer Portal API で
「<名前> AppStore CLI」というプロファイルを bundle id ごとに作り(既にあれば再利用)、
~/Library/MobileDevice/Provisioning Profiles/ と Xcode 16+ の UserData 配下に置く。
標準出力に {bundleId: profileName} の JSON を出す(exportOptions の provisioningProfiles 用)。
"""
import argparse
import base64
import importlib.util
import json
import os
import plistlib
import subprocess
import sys

_spec = importlib.util.spec_from_file_location(
    "distribute", os.path.join(os.path.dirname(os.path.abspath(__file__)), "testflight_distribute.py"))
_dist = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_dist)
Client = _dist.Client

INSTALL_DIRS = [
    os.path.expanduser("~/Library/MobileDevice/Provisioning Profiles"),
    os.path.expanduser("~/Library/Developer/Xcode/UserData/Provisioning Profiles"),
]


def log(msg):
    print(msg, file=sys.stderr)


def distribution_certificate(client):
    certs = client.get("/v1/certificates", **{"filter[certificateType]": "DISTRIBUTION", "limit": 20}).get("data", [])
    if not certs:
        sys.exit("Apple Distribution 証明書が見つかりません。Xcode > Settings > Accounts > Manage Certificates で作成してください")
    # 期限が一番先のものを使う
    certs.sort(key=lambda c: c["attributes"]["expirationDate"], reverse=True)
    return certs[0]


def bundle_id_resource(client, identifier):
    data = client.get("/v1/bundleIds", **{"filter[identifier]": identifier}).get("data", [])
    exact = [b for b in data if b["attributes"]["identifier"] == identifier]
    if not exact:
        sys.exit(f"Bundle ID が Developer Portal に登録されていません: {identifier}")
    return exact[0]


def ensure_profile(client, name, bundle, cert):
    existing = client.get("/v1/profiles", **{"filter[name]": name, "filter[profileType]": "IOS_APP_STORE"}).get("data", [])
    for p in existing:
        if p["attributes"]["profileState"] == "ACTIVE":
            log(f"  {name}: 既存のプロファイルを使用")
            return p
        log(f"  {name}: {p['attributes']['profileState']} なので作り直す")
        client.request("DELETE", f"/v1/profiles/{p['id']}")
    created = client.request(
        "POST", "/v1/profiles",
        {"data": {"type": "profiles",
                  "attributes": {"name": name, "profileType": "IOS_APP_STORE"},
                  "relationships": {
                      "bundleId": {"data": {"type": "bundleIds", "id": bundle["id"]}},
                      "certificates": {"data": [{"type": "certificates", "id": cert["id"]}]},
                  }}},
    )["data"]
    log(f"  {name}: 作成")
    return created


def install(profile):
    content = base64.b64decode(profile["attributes"]["profileContent"])
    plist_xml = subprocess.run(["security", "cms", "-D"], input=content, capture_output=True, check=True).stdout
    uuid = plistlib.loads(plist_xml)["UUID"]
    for d in INSTALL_DIRS:
        os.makedirs(d, exist_ok=True)
        with open(os.path.join(d, f"{uuid}.mobileprovision"), "wb") as f:
            f.write(content)
    return uuid


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--key-id", required=True)
    parser.add_argument("--issuer-id", required=True)
    parser.add_argument("--key-path", required=True)
    parser.add_argument("--bundle-ids", required=True, help="カンマ区切り(アプリ本体と拡張)")
    parser.add_argument("--name-prefix", required=True, help='プロファイル名の接頭辞(例 "SlidysFlutter")')
    args = parser.parse_args()

    client = Client(args.key_id, args.issuer_id, args.key_path)
    cert = distribution_certificate(client)
    log(f"distribution certificate: {cert['attributes']['name']} (expires {cert['attributes']['expirationDate'][:10]})")
    mapping = {}
    for i, identifier in enumerate(x.strip() for x in args.bundle_ids.split(",") if x.strip()):
        bundle = bundle_id_resource(client, identifier)
        suffix = "" if i == 0 else f" {identifier.rsplit('.', 1)[-1]}"
        name = f"{args.name_prefix}{suffix} AppStore CLI"
        profile = ensure_profile(client, name, bundle, cert)
        uuid = install(profile)
        log(f"  installed {uuid}.mobileprovision")
        mapping[identifier] = name
    print(json.dumps(mapping))


if __name__ == "__main__":
    main()
