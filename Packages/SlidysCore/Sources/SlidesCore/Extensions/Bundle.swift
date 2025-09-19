//
//  Created by yugo.sugiyama on 2025/05/20
//  Copyright ©Sugiy All rights reserved.
//

import SwiftUI

public let imageBundle = Bundle.myModule
private class CurrentBundleFinder {}
extension Foundation.Bundle {
    static var myModule: Bundle = {
        /* The name of your local package, prepended by "LocalPackages_" for iOS and "PackageName_" for macOS. You may have same PackageName and TargetName*/
        let bundleNameIOS = "LocalPackages_SlidesCore"
        let bundleNameMacOsDebug = "SlidysCore_SlidesCore"
        // For macOS release builds, the bundle name is usually just the target name
        let bundleNameMacOsRelease = "SlidesCore_SlidesCore"

        let candidates = [
            /* Bundle should be present here when the package is linked into an App. */
            Bundle.main.resourceURL,
            /* Bundle should be present here when the package is linked into a framework. */
            Bundle(for: CurrentBundleFinder.self).resourceURL,
            /* For command-line tools. */
            Bundle.main.bundleURL,
            /* Bundle should be present here when running previews from a different package (this is the path to "…/Debug-iphonesimulator/"). */
            Bundle(for: CurrentBundleFinder.self).resourceURL?.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent(),
            Bundle(for: CurrentBundleFinder.self).resourceURL?.deletingLastPathComponent().deletingLastPathComponent(),
            /* Additional paths for macOS app bundles */
            Bundle.main.bundleURL.appendingPathComponent("Contents").appendingPathComponent("Resources"),
            Bundle.main.bundleURL.appendingPathComponent("Contents").appendingPathComponent("Frameworks"),
        ]

        for candidate in candidates {
            let bundlePathiOS = candidate?.appendingPathComponent(bundleNameIOS + ".bundle")
            let bundlePathMacOSDebug = candidate?.appendingPathComponent(bundleNameMacOsDebug + ".bundle")
            let bundlePathMacOSRelease = candidate?.appendingPathComponent(bundleNameMacOsRelease + ".bundle")

            if let bundle = bundlePathiOS.flatMap(Bundle.init(url:)) {
                return bundle
            } else if let bundle = bundlePathMacOSDebug.flatMap(Bundle.init(url:)) {
                return bundle
            } else if let bundle = bundlePathMacOSRelease.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }

        // If we still haven't found the bundle, try to look for the resources directly in the main bundle
        // This can happen in release builds where resources are merged into the main app bundle
        if Bundle.main.path(forResource: "opening_input", ofType: "mp4") != nil {
            return Bundle.main
        }

        fatalError("unable to find bundle")
    }()
}
