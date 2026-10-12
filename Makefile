link_template:
	sh scripts/link_template.sh

asset-pack-build:
	sh Scripts/build-asset-pack.sh build

asset-pack-upload:
	sh Scripts/build-asset-pack.sh upload both

asset-pack-upload-slidys:
	sh Scripts/build-asset-pack.sh upload slidys

asset-pack-upload-flutter:
	sh Scripts/build-asset-pack.sh upload flutter

asset-pack:
	sh Scripts/build-asset-pack.sh all both

asset-pack-slidys:
	sh Scripts/build-asset-pack.sh all slidys

asset-pack-flutter:
	sh Scripts/build-asset-pack.sh all flutter
# ---- TestFlight(手元から archive → upload → 外部テスター配布) ----
# 認証は .env の ASC_KEY_ID / ASC_ISSUER_ID を使う。詳細は docs/testflight.md
# 例: make testflight-slidys / make testflight-flutter
#     make testflight-archive-slidys → make testflight-upload-slidys → make testflight-distribute-slidys
# (macOS 標準の make 3.81 はパターン規則の優先順位が弱いので、明示的に列挙している)
testflight-slidys:
	sh Scripts/testflight.sh all slidys

testflight-flutter:
	sh Scripts/testflight.sh all flutter

testflight-archive-slidys:
	sh Scripts/testflight.sh archive slidys

testflight-archive-flutter:
	sh Scripts/testflight.sh archive flutter

testflight-export-slidys:
	sh Scripts/testflight.sh export slidys

testflight-export-flutter:
	sh Scripts/testflight.sh export flutter

testflight-upload-slidys:
	sh Scripts/testflight.sh upload slidys

testflight-upload-flutter:
	sh Scripts/testflight.sh upload flutter

testflight-distribute-slidys:
	sh Scripts/testflight.sh distribute slidys

testflight-distribute-flutter:
	sh Scripts/testflight.sh distribute flutter

# テスター管理。例:
#   make testflight-testers-slidys                                   # 全グループのテスター一覧
#   make testflight-tester-add-slidys EMAIL=a@example.com            # 既定グループ(TESTFLIGHT_GROUPS の先頭)に追加
#   make testflight-tester-add-slidys EMAIL=a@example.com,b@example.com GROUP=ExternalTestGroup FIRST_NAME=Taro LAST_NAME=Yamada
#   make testflight-tester-remove-slidys EMAIL=a@example.com GROUP=ExternalTestGroup
testflight-testers-slidys:
	sh Scripts/testflight.sh testers slidys

testflight-testers-flutter:
	sh Scripts/testflight.sh testers flutter

testflight-tester-add-slidys:
	sh Scripts/testflight.sh tester-add slidys

testflight-tester-add-flutter:
	sh Scripts/testflight.sh tester-add flutter

testflight-tester-remove-slidys:
	sh Scripts/testflight.sh tester-remove slidys

testflight-tester-remove-flutter:
	sh Scripts/testflight.sh tester-remove flutter
