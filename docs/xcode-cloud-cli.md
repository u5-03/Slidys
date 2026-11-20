# Xcode Cloud / Deploy External TestFlight をCLIで実行する

このリポジトリのXcode Cloud実行・状態確認は、**ブラウザではなくCLI（App Store Connect API）で行う**。
ユーザーからブラウザ操作を明示指定された場合だけ切り替える。
通常の対象は **Slidysのみ**。SlidysFlutterは明示指定時のみ。

認証情報は[既存のTestFlight手順](testflight.md#準備初回のみ)と共通。
`Scripts/app_store_connect_api.py` は既存のJWT署名処理を再利用し、秘密鍵・トークンを出力しない。
APIレスポンスのartifact `downloadUrl` は署名付きURLなので共有ログへ貼らない。

## 1. 対象ブランチとコミットを確認してPush

```sh
git branch --show-current
git status --short
git log -1 --format='%H %s'
git push
```

Saitama.swiftの作業ブランチは `codex/saitama-swift-3d-quiz`。
未コミットの変更はCloudに含まれない。無関係なローカル変更をまとめてコミットしない。

## 2. ワークフローとブランチ参照を確認

Slidysの既知ID（削除・再作成時には再取得する）:

| 対象 | ID |
|---|---|
| App | `6633443299` |
| Cloud Product | `D935BE91-59C2-4B3A-BD44-350EE835B3CF` |
| Deploy External TestFlight | `A5D21F7B-36CC-4EBF-81B4-C92E37681EC0` |
| Git repository | `74508ca8-131d-4642-a4d2-89c85354e8f0` |
| Saitama作業ブランチ参照 | `7e470cff-3356-4bd0-9141-93fd0db7487d` |

```sh
python3 Scripts/app_store_connect_api.py GET \
  /v1/ciWorkflows/A5D21F7B-36CC-4EBF-81B4-C92E37681EC0
python3 Scripts/app_store_connect_api.py GET \
  /v1/scmGitReferences/7e470cff-3356-4bd0-9141-93fd0db7487d
```

ワークフローのschemeがSlidys、ArchiveがiOS・macOS・visionOSであることを確認する。
別ブランチを使う場合は `/v1/scmRepositories/{repositoryId}/gitReferences` で参照を調べる。

## 3. 実行

```sh
cat > /tmp/slidys-cloud-start.json <<'JSON'
{
  "data": {
    "type": "ciBuildRuns",
    "attributes": {"clean": false},
    "relationships": {
      "workflow": {"data": {"type": "ciWorkflows", "id": "A5D21F7B-36CC-4EBF-81B4-C92E37681EC0"}},
      "sourceBranchOrTag": {"data": {"type": "scmGitReferences", "id": "7e470cff-3356-4bd0-9141-93fd0db7487d"}}
    }
  }
}
JSON
python3 Scripts/app_store_connect_api.py POST /v1/ciBuildRuns \
  /tmp/slidys-cloud-start.json > /tmp/slidys-cloud-run.json
```

レスポンスの `data.id` がrun ID、`attributes.number` がビルド番号。
開始直後の `sourceCommit.commitSha` は空の場合があるので、次のGETで必ず期待するSHAと照合する。

## 4. 状態・エラー・成果物を確認

以下のプレースホルダーを実際のIDへ置き換える。

```sh
python3 Scripts/app_store_connect_api.py GET '/v1/ciBuildRuns/{runId}'
python3 Scripts/app_store_connect_api.py GET '/v1/ciBuildRuns/{runId}/actions'
python3 Scripts/app_store_connect_api.py GET '/v1/ciBuildActions/{actionId}/issues'
python3 Scripts/app_store_connect_api.py GET '/v1/ciBuildActions/{actionId}/artifacts' \
  > /tmp/slidys-cloud-artifacts.json
python3 Scripts/app_store_connect_api.py GET '/v1/ciBuildRuns/{runId}/builds'
python3 Scripts/app_store_connect_api.py GET '/v1/builds/{buildId}?include=preReleaseVersion'
```

- アクション一覧は **`/actions`**。`/buildActions`ではない。
- 各Archiveの `completionStatus=SUCCEEDED`、全体の完了を確認する。
- `/issues` でERRORを確認。開始成功だけでビルド成功と報告しない。
- `ARCHIVE_EXPORT` の `app-store.zip` を確認。iOS・visionOSにはIPA、macOSにはPKGが入る。
- 各buildの `processingState=VALID` を確認する。プラットフォームは個別buildの `preReleaseVersion` で判別する。
- Apple側がVALIDでもCloudの終了処理が残ることがある。その場合は両者を区別して報告する。
- 監視は間隔をあけ、変更がない状態を何度も報告しない。

## 5. 「配布準備だけ」の場合

**ビルド実行・アップロードと、テスターへの配布は別の操作。**
ユーザーが配布を保留している場合、`make testflight-slidys` や `distribute` を実行せず、
テスターグループへの追加、Beta App Review提出、通知を行わない。

既存Cloudワークフローには内部テストの後処理がある。CLIで起動しても無効になるわけではない。
公式APIのCiWorkflowスキーマでは後処理設定が公開されていないため、未確認のパラメーターで無効化しない。
配布保留時は自動配布設定も確認し、抑止できない場合は開始前にその制約を伝える。

グループへの追加有無は以下で検証する（build側のbetaGroups関係取得は403になる場合がある）。

```sh
# 内部: InternalTestGroup
python3 Scripts/app_store_connect_api.py GET \
  '/v1/betaGroups/2dad975d-83a3-490e-b5db-fe33ccc6d6df/builds?limit=200'
# 外部: ExternalTestGroup
python3 Scripts/app_store_connect_api.py GET \
  '/v1/betaGroups/bfd7556c-3aed-481f-9c7c-6b94c083a948/builds?limit=200'
```

今回生成したbuild IDが含まれないことを確認する。ページがある場合は次ページも確認する。
配布を別途指示されたときだけグループに追加する。内部配布後は
`/v1/builds/{buildId}/buildBetaDetail` の `internalBuildState=IN_BETA_TESTING` も確認する。

## Background Assetsは別手順

アプリビルドとアセットパックのアップロード・審査は別。
[Background Assets手順](background-assets-guide.md)を参照する。
アップロードは `Scripts/build-asset-pack.sh all slidys`。
既に同じ動画入りパックがCOMPLETEなら、重複アップロードせずそのバージョンを使用する。
アセット審査提出にブラウザが必要な場合でも、Cloudビルド実行をブラウザへ戻さない。

## 2026-11-21の実行記録

- ビルド101、run ID: `33fcfb4c-09ac-4955-9403-ad920b1750e5`
- commit: `d9b5f0c6e3c1035c46d869c73a9efc3c910b3b20`
- iOS・macOS・visionOSの配布用成果物生成、全buildのVALIDを確認。
- 確認時点では内部・外部グループに未追加。CloudのvisionOS終了処理は継続中だった。
- 前回visionOSで `allowsExternalPlayback is unavailable` が発生し、`#if !os(visionOS)` で解消。
