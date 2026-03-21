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