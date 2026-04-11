#!/usr/bin/env python3
"""
Adds SlidysShareScreenshots target to SlidysShare.xcodeproj/project.pbxproj.
Uses PBXFileSystemSynchronizedRootGroup (Xcode 16+ style).
"""

import re
import sys
import os

PBXPROJ = os.path.join(os.path.dirname(__file__), '..', 'SlidysShare.xcodeproj', 'project.pbxproj')

# New UUIDs for screenshot target objects
UUIDS = {
    'target':           'CC000001000000000000AA01',
    'product_ref':      'CC000002000000000000AA02',
    'sources_phase':    'CC000003000000000000AA03',
    'frameworks_phase': 'CC000004000000000000AA04',
    'resources_phase':  'CC000005000000000000AA05',
    'debug_config':     'CC000006000000000000AA06',
    'release_config':   'CC000007000000000000AA07',
    'config_list':      'CC000008000000000000AA08',
    'synced_group':     'CC000009000000000000AA09',
    'pkg_ref_appstore': 'CC00000A000000000000AA0A',
    'pkg_dep_core':     'CC00000B000000000000AA0B',
    'pkg_dep_slidecore':'CC00000C000000000000AA0C',
    'build_file_core':  'CC00000D000000000000AA0D',
    'build_file_score': 'CC00000E000000000000AA0E',
    'exception_set':    'CC00000F000000000000AA0F',
    'build_file_storekit': 'CC000010000000000000AA10',
}

def main():
    with open(PBXPROJ, 'r') as f:
        content = f.read()

    if 'SlidysShareScreenshots' in content:
        print("Target 'SlidysShareScreenshots' already exists. Skipping.")
        return

    # --- 1. Add PBXBuildFile entries ---
    build_files = f"""		{UUIDS['build_file_core']} /* AppStoreScreenshotTestCore in Frameworks */ = {{isa = PBXBuildFile; productRef = {UUIDS['pkg_dep_core']} /* AppStoreScreenshotTestCore */; }};
		{UUIDS['build_file_score']} /* SlidysShareCore in Frameworks */ = {{isa = PBXBuildFile; productRef = {UUIDS['pkg_dep_slidecore']} /* SlidysShareCore */; }};
		{UUIDS['build_file_storekit']} /* StoreKit.framework in Frameworks */ = {{isa = PBXBuildFile; fileRef = 68B3DE2A2F76CE50008D091C /* StoreKit.framework */; }};"""
    content = content.replace(
        '/* End PBXBuildFile section */',
        build_files + '\n/* End PBXBuildFile section */'
    )

    # --- 2. Add PBXFileReference for product ---
    product_ref = f'\t\t{UUIDS["product_ref"]} /* SlidysShareScreenshots.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = SlidysShareScreenshots.app; sourceTree = BUILT_PRODUCTS_DIR; }};'
    content = content.replace(
        '/* End PBXFileReference section */',
        product_ref + '\n/* End PBXFileReference section */'
    )

    # --- 3. Add PBXFileSystemSynchronizedBuildFileExceptionSet ---
    # Exclude SlidysShareApp.swift from screenshot target when SlidysShare group is added
    exception_section = f"""
/* Begin PBXFileSystemSynchronizedBuildFileExceptionSet section */
		{UUIDS['exception_set']} /* PBXFileSystemSynchronizedBuildFileExceptionSet */ = {{
			isa = PBXFileSystemSynchronizedBuildFileExceptionSet;
			membershipExceptions = (
				SlidysShareApp.swift,
			);
			target = {UUIDS['target']} /* SlidysShareScreenshots */;
		}};
/* End PBXFileSystemSynchronizedBuildFileExceptionSet section */
"""

    # --- 4. Add new PBXFileSystemSynchronizedRootGroup for SlidysShareScreenshots ---
    synced_group = f'\t\t{UUIDS["synced_group"]} /* SlidysShareScreenshots */ = {{\n\t\t\tisa = PBXFileSystemSynchronizedRootGroup;\n\t\t\tpath = SlidysShareScreenshots;\n\t\t\tsourceTree = "<group>";\n\t\t}};'
    # Also add exceptions to existing SlidysShare group
    content = content.replace(
        '/* End PBXFileSystemSynchronizedRootGroup section */',
        synced_group + '\n/* End PBXFileSystemSynchronizedRootGroup section */'
    )

    # Add exceptions array to existing SlidysShare synced group
    content = content.replace(
        '682E4D892F70CBE700DA3D04 /* SlidysShare */ = {\n\t\t\tisa = PBXFileSystemSynchronizedRootGroup;\n\t\t\tpath = SlidysShare;\n\t\t\tsourceTree = "<group>";',
        f'682E4D892F70CBE700DA3D04 /* SlidysShare */ = {{\n\t\t\tisa = PBXFileSystemSynchronizedRootGroup;\n\t\t\texceptions = (\n\t\t\t\t{UUIDS["exception_set"]} /* PBXFileSystemSynchronizedBuildFileExceptionSet */,\n\t\t\t);\n\t\t\tpath = SlidysShare;\n\t\t\tsourceTree = "<group>";'
    )

    # Insert exception section before PBXFileSystemSynchronizedRootGroup section
    content = content.replace(
        '/* Begin PBXFileSystemSynchronizedRootGroup section */',
        exception_section + '/* Begin PBXFileSystemSynchronizedRootGroup section */'
    )

    # --- 5. Add build phases ---
    sources = f"""\t\t{UUIDS['sources_phase']} /* Sources */ = {{
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};"""
    content = content.replace(
        '/* End PBXSourcesBuildPhase section */',
        sources + '\n/* End PBXSourcesBuildPhase section */'
    )

    frameworks = f"""\t\t{UUIDS['frameworks_phase']} /* Frameworks */ = {{
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
				{UUIDS['build_file_core']} /* AppStoreScreenshotTestCore in Frameworks */,
				{UUIDS['build_file_score']} /* SlidysShareCore in Frameworks */,
				{UUIDS['build_file_storekit']} /* StoreKit.framework in Frameworks */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};"""
    content = content.replace(
        '/* End PBXFrameworksBuildPhase section */',
        frameworks + '\n/* End PBXFrameworksBuildPhase section */'
    )

    resources = f"""\t\t{UUIDS['resources_phase']} /* Resources */ = {{
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};"""
    content = content.replace(
        '/* End PBXResourcesBuildPhase section */',
        resources + '\n/* End PBXResourcesBuildPhase section */'
    )

    # --- 6. Add product to Products group ---
    content = content.replace(
        '682E4D9E2F70CBEA00DA3D04 /* SlidysShareUITests.xctest */,\n\t\t\t);\n\t\t\tname = Products;',
        f'682E4D9E2F70CBEA00DA3D04 /* SlidysShareUITests.xctest */,\n\t\t\t\t{UUIDS["product_ref"]} /* SlidysShareScreenshots.app */,\n\t\t\t);\n\t\t\tname = Products;'
    )

    # --- 7. Add SlidysShareScreenshots group to main group children ---
    content = content.replace(
        '682E4DA12F70CBEA00DA3D04 /* SlidysShareUITests */,\n\t\t\t\t682E4ECC2F744D6900DA3D04 /* Frameworks */',
        f'682E4DA12F70CBEA00DA3D04 /* SlidysShareUITests */,\n\t\t\t\t{UUIDS["synced_group"]} /* SlidysShareScreenshots */,\n\t\t\t\t682E4ECC2F744D6900DA3D04 /* Frameworks */'
    )

    # --- 8. Add native target ---
    target_entry = f"""\t\t{UUIDS['target']} /* SlidysShareScreenshots */ = {{
			isa = PBXNativeTarget;
			buildConfigurationList = {UUIDS['config_list']} /* Build configuration list for PBXNativeTarget "SlidysShareScreenshots" */;
			buildPhases = (
				{UUIDS['sources_phase']} /* Sources */,
				{UUIDS['frameworks_phase']} /* Frameworks */,
				{UUIDS['resources_phase']} /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			fileSystemSynchronizedGroups = (
				682E4D892F70CBE700DA3D04 /* SlidysShare */,
				{UUIDS['synced_group']} /* SlidysShareScreenshots */,
			);
			name = SlidysShareScreenshots;
			packageProductDependencies = (
				{UUIDS['pkg_dep_core']} /* AppStoreScreenshotTestCore */,
				{UUIDS['pkg_dep_slidecore']} /* SlidysShareCore */,
			);
			productName = SlidysShareScreenshots;
			productReference = {UUIDS['product_ref']} /* SlidysShareScreenshots.app */;
			productType = "com.apple.product-type.application";
		}};"""
    content = content.replace(
        '/* End PBXNativeTarget section */',
        target_entry + '\n/* End PBXNativeTarget section */'
    )

    # --- 9. Add target to project targets list ---
    content = content.replace(
        '682E4D9D2F70CBEA00DA3D04 /* SlidysShareUITests */,\n\t\t\t\t);',
        f'682E4D9D2F70CBEA00DA3D04 /* SlidysShareUITests */,\n\t\t\t\t\t{UUIDS["target"]} /* SlidysShareScreenshots */,\n\t\t\t\t);'
    )

    # --- 10. Add TargetAttributes ---
    content = content.replace(
        '682E4D9D2F70CBEA00DA3D04 = {\n\t\t\t\t\t\tCreatedOnToolsVersion = 26.3;\n\t\t\t\t\t\tTestTargetID = 682E4D862F70CBE700DA3D04;\n\t\t\t\t\t};\n\t\t\t\t};',
        f'682E4D9D2F70CBEA00DA3D04 = {{\n\t\t\t\t\t\tCreatedOnToolsVersion = 26.3;\n\t\t\t\t\t\tTestTargetID = 682E4D862F70CBE700DA3D04;\n\t\t\t\t\t}};\n\t\t\t\t\t{UUIDS["target"]} = {{\n\t\t\t\t\t\tCreatedOnToolsVersion = 26.3;\n\t\t\t\t\t}};\n\t\t\t\t}};'
    )

    # --- 11. Add build configurations ---
    # Common settings from main target
    debug_config = f"""\t\t{UUIDS['debug_config']} /* Debug */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = 669226BDWM;
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_FILE = SlidysShareScreenshots/Info.plist;
				INFOPLIST_KEY_CFBundleDisplayName = SlidysShareScreenshots;
				"INFOPLIST_KEY_UIApplicationSceneManifest_Generation[sdk=iphoneos*]" = YES;
				"INFOPLIST_KEY_UIApplicationSceneManifest_Generation[sdk=iphonesimulator*]" = YES;
				"INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents[sdk=iphoneos*]" = YES;
				"INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents[sdk=iphonesimulator*]" = YES;
				"INFOPLIST_KEY_UILaunchScreen_Generation[sdk=iphoneos*]" = YES;
				"INFOPLIST_KEY_UILaunchScreen_Generation[sdk=iphonesimulator*]" = YES;
				"INFOPLIST_KEY_UIStatusBarStyle[sdk=iphoneos*]" = UIStatusBarStyleDefault;
				"INFOPLIST_KEY_UIStatusBarStyle[sdk=iphonesimulator*]" = UIStatusBarStyleDefault;
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				IPHONEOS_DEPLOYMENT_TARGET = 26.0;
				LD_RUNPATH_SEARCH_PATHS = "@executable_path/Frameworks";
				"LD_RUNPATH_SEARCH_PATHS[sdk=macosx*]" = "@executable_path/../Frameworks";
				MACOSX_DEPLOYMENT_TARGET = 26.0;
				MARKETING_VERSION = 1.0.0;
				PRODUCT_BUNDLE_IDENTIFIER = yugo.sugiyama.SlidysShare.Screenshots;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SDKROOT = auto;
				SUPPORTED_PLATFORMS = "iphoneos iphonesimulator macosx xros xrsimulator";
				SWIFT_APPROACHABLE_CONCURRENCY = YES;
				SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor;
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2,7";
				XROS_DEPLOYMENT_TARGET = 26.0;
			}};
			name = Debug;
		}};"""

    release_config = f"""\t\t{UUIDS['release_config']} /* Release */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = 669226BDWM;
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_FILE = SlidysShareScreenshots/Info.plist;
				INFOPLIST_KEY_CFBundleDisplayName = SlidysShareScreenshots;
				"INFOPLIST_KEY_UIApplicationSceneManifest_Generation[sdk=iphoneos*]" = YES;
				"INFOPLIST_KEY_UIApplicationSceneManifest_Generation[sdk=iphonesimulator*]" = YES;
				"INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents[sdk=iphoneos*]" = YES;
				"INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents[sdk=iphonesimulator*]" = YES;
				"INFOPLIST_KEY_UILaunchScreen_Generation[sdk=iphoneos*]" = YES;
				"INFOPLIST_KEY_UILaunchScreen_Generation[sdk=iphonesimulator*]" = YES;
				"INFOPLIST_KEY_UIStatusBarStyle[sdk=iphoneos*]" = UIStatusBarStyleDefault;
				"INFOPLIST_KEY_UIStatusBarStyle[sdk=iphonesimulator*]" = UIStatusBarStyleDefault;
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				IPHONEOS_DEPLOYMENT_TARGET = 26.0;
				LD_RUNPATH_SEARCH_PATHS = "@executable_path/Frameworks";
				"LD_RUNPATH_SEARCH_PATHS[sdk=macosx*]" = "@executable_path/../Frameworks";
				MACOSX_DEPLOYMENT_TARGET = 26.0;
				MARKETING_VERSION = 1.0.0;
				PRODUCT_BUNDLE_IDENTIFIER = yugo.sugiyama.SlidysShare.Screenshots;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SDKROOT = auto;
				SUPPORTED_PLATFORMS = "iphoneos iphonesimulator macosx xros xrsimulator";
				SWIFT_APPROACHABLE_CONCURRENCY = YES;
				SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor;
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2,7";
				XROS_DEPLOYMENT_TARGET = 26.0;
			}};
			name = Release;
		}};"""

    content = content.replace(
        '/* End XCBuildConfiguration section */',
        debug_config + '\n' + release_config + '\n/* End XCBuildConfiguration section */'
    )

    # --- 12. Add configuration list ---
    config_list = f"""\t\t{UUIDS['config_list']} /* Build configuration list for PBXNativeTarget "SlidysShareScreenshots" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{UUIDS['debug_config']} /* Debug */,
				{UUIDS['release_config']} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};"""
    content = content.replace(
        '/* End XCConfigurationList section */',
        config_list + '\n/* End XCConfigurationList section */'
    )

    # --- 13. Add package references ---
    # AppStoreScreenshotTest local package
    pkg_ref = f'\t\t{UUIDS["pkg_ref_appstore"]} /* XCLocalSwiftPackageReference "../../../AppStoreScreenshotTest" */ = {{\n\t\t\tisa = XCLocalSwiftPackageReference;\n\t\t\trelativePath = ../../../AppStoreScreenshotTest;\n\t\t}};'
    content = content.replace(
        '/* End XCLocalSwiftPackageReference section */',
        pkg_ref + '\n/* End XCLocalSwiftPackageReference section */'
    )

    # Add to project's packageReferences list
    content = content.replace(
        '682E4DE32F71539D00DA3D04 /* XCLocalSwiftPackageReference "../../Packages/SlidysShareCore" */,\n\t\t\t\t);',
        f'682E4DE32F71539D00DA3D04 /* XCLocalSwiftPackageReference "../../Packages/SlidysShareCore" */,\n\t\t\t\t\t{UUIDS["pkg_ref_appstore"]} /* XCLocalSwiftPackageReference "../../../AppStoreScreenshotTest" */,\n\t\t\t\t);'
    )

    # --- 14. Add package product dependencies ---
    pkg_deps = f"""\t\t{UUIDS['pkg_dep_core']} /* AppStoreScreenshotTestCore */ = {{
			isa = XCSwiftPackageProductDependency;
			package = {UUIDS['pkg_ref_appstore']} /* XCLocalSwiftPackageReference "../../../AppStoreScreenshotTest" */;
			productName = AppStoreScreenshotTestCore;
		}};
		{UUIDS['pkg_dep_slidecore']} /* SlidysShareCore */ = {{
			isa = XCSwiftPackageProductDependency;
			productName = SlidysShareCore;
		}};"""
    content = content.replace(
        '/* End XCSwiftPackageProductDependency section */',
        pkg_deps + '\n/* End XCSwiftPackageProductDependency section */'
    )

    with open(PBXPROJ, 'w') as f:
        f.write(content)

    print("Done! Target 'SlidysShareScreenshots' added to project.")
    print("  - New file system synced group: SlidysShareScreenshots/")
    print("  - SlidysShare/ group shared (SlidysShareApp.swift excluded)")
    print("  - AppStoreScreenshotTestCore package added")
    print("  - SlidysShareCore package linked")

if __name__ == '__main__':
    main()
