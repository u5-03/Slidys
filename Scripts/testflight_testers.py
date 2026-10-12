#!/usr/bin/env python3
"""TestFlight のテスターを一覧・追加(招待)・削除する(App Store Connect API)。

Scripts/testflight.sh の testers / tester-add / tester-remove から呼ばれる。
認証は testflight_distribute.py と共通(API キー + JWT)。

  list   : グループごとのテスターを表示する
  add    : メールアドレスでテスターをグループに追加する。外部グループなら未登録の人は新規作成され、
           グループにビルドがあれば TestFlight から招待メールが届く。
           内部グループは App Store Connect のユーザー(チームメンバー)しか入れられないので、
           既存テスターとして見つからなければ案内を出して終了する。
  remove : テスターをグループから外す(テスター自体は残る)
"""
import argparse
import importlib.util
import os
import sys

_spec = importlib.util.spec_from_file_location(
    "distribute", os.path.join(os.path.dirname(os.path.abspath(__file__)), "testflight_distribute.py"))
_dist = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_dist)
Client = _dist.Client
find_app = _dist.find_app


def groups_of(client, app_id):
    data = client.get("/v1/betaGroups", **{"filter[app]": app_id, "limit": 200}).get("data", [])
    return {g["attributes"]["name"]: g for g in data}


def testers_in_group(client, group_id):
    return client.get(f"/v1/betaGroups/{group_id}/betaTesters", limit=200).get("data", [])


def find_tester(client, app_id, email):
    data = client.get("/v1/betaTesters", **{"filter[email]": email, "filter[apps]": app_id, "limit": 5}).get("data", [])
    return data[0] if data else None


def cmd_list(client, app_id, group_name):
    groups = groups_of(client, app_id)
    targets = [groups[group_name]] if group_name else list(groups.values())
    if group_name and group_name not in groups:
        sys.exit(f"Beta group '{group_name}' not found. Existing: {sorted(groups)}")
    for g in targets:
        a = g["attributes"]
        kind = "internal" if a.get("isInternalGroup") else "external"
        auto = " / 全ビルド自動配布" if a.get("hasAccessToAllBuilds") else ""
        testers = testers_in_group(client, g["id"])
        print(f"[{a['name']}] ({kind}{auto}) {len(testers)} 人")
        for t in testers:
            ta = t["attributes"]
            name = " ".join(x for x in (ta.get("firstName"), ta.get("lastName")) if x)
            print(f"  - {ta.get('email')}  {name}  state={ta.get('state')}")


def cmd_add(client, app_id, group_name, emails, first, last):
    groups = groups_of(client, app_id)
    group = groups.get(group_name)
    if group is None:
        sys.exit(f"Beta group '{group_name}' not found. Existing: {sorted(groups)}")
    is_internal = bool(group["attributes"].get("isInternalGroup"))
    for email in emails:
        tester = find_tester(client, app_id, email)
        if tester is None:
            if is_internal:
                print(f"  {email}: 内部グループには App Store Connect のユーザーしか追加できません。"
                      "先に「ユーザーとアクセス」から招待してから再実行してください")
                continue
            attrs = {"email": email}
            if first:
                attrs["firstName"] = first
            if last:
                attrs["lastName"] = last
            tester = client.request(
                "POST", "/v1/betaTesters",
                {"data": {"type": "betaTesters", "attributes": attrs,
                          "relationships": {"betaGroups": {"data": [{"type": "betaGroups", "id": group["id"]}]}}}},
            )["data"]
            print(f"  {email}: 新規テスターとして作成し '{group_name}' に追加(招待メール送信)")
        else:
            members = {t["id"] for t in testers_in_group(client, group["id"])}
            if tester["id"] in members:
                print(f"  {email}: すでに '{group_name}' に登録済み (state={tester['attributes'].get('state')})")
                continue
            try:
                client.request(
                    "POST", f"/v1/betaGroups/{group['id']}/relationships/betaTesters",
                    {"data": [{"type": "betaTesters", "id": tester["id"]}]},
                )
                print(f"  {email}: 既存テスターを '{group_name}' に追加")
            except RuntimeError as e:
                # 409 STATE_ERROR: すでに割り当て済みなど。エラーにせず続行する
                if "HTTP 409" in str(e):
                    print(f"  {email}: '{group_name}' に追加できませんでした(すでに割り当て済みの可能性)")
                else:
                    raise


def cmd_remove(client, app_id, group_name, emails):
    groups = groups_of(client, app_id)
    group = groups.get(group_name)
    if group is None:
        sys.exit(f"Beta group '{group_name}' not found. Existing: {sorted(groups)}")
    for email in emails:
        tester = find_tester(client, app_id, email)
        if tester is None:
            print(f"  {email}: テスターが見つかりません")
            continue
        client.request(
            "DELETE", f"/v1/betaGroups/{group['id']}/relationships/betaTesters",
            {"data": [{"type": "betaTesters", "id": tester["id"]}]},
        )
        print(f"  {email}: '{group_name}' から削除")


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("command", choices=["list", "add", "remove"])
    parser.add_argument("--key-id", required=True)
    parser.add_argument("--issuer-id", required=True)
    parser.add_argument("--key-path", required=True)
    parser.add_argument("--bundle-id", required=True)
    parser.add_argument("--group", default=None, help="グループ名(list では省略可 = 全グループ)")
    parser.add_argument("--emails", default="", help="カンマ区切りのメールアドレス(add / remove)")
    parser.add_argument("--first-name", default=None)
    parser.add_argument("--last-name", default=None)
    args = parser.parse_args()

    client = Client(args.key_id, args.issuer_id, args.key_path)
    app_id = find_app(client, args.bundle_id)
    emails = [e.strip() for e in args.emails.split(",") if e.strip()]

    if args.command == "list":
        cmd_list(client, app_id, args.group)
    elif args.command == "add":
        if not args.group or not emails:
            sys.exit("add には --group と --emails が必要です")
        cmd_add(client, app_id, args.group, emails, args.first_name, args.last_name)
    elif args.command == "remove":
        if not args.group or not emails:
            sys.exit("remove には --group と --emails が必要です")
        cmd_remove(client, app_id, args.group, emails)


if __name__ == "__main__":
    main()
