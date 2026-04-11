import SwiftUI
import OSLog
import AppStoreScreenshotTestCore

private let logger = Logger(
    subsystem: "yugo.sugiyama.SlidysShare.Screenshots",
    category: "ScreenshotApp"
)

@main
@MainActor
struct ScreenshotApp: App {
    private let screenshotData: ScreenshotData?

    /// Read screenshot index and language from env vars or a temp config file.
    /// On macOS, `open -a --env` doesn't relay env vars on app relaunch,
    /// so the shell script writes a temp JSON file as fallback.
    private static func readConfig() -> (index: Int, language: String) {
        let envIndex = ProcessInfo.processInfo.environment["SCREENSHOT_INDEX"]
        let envLang = ProcessInfo.processInfo.environment["SCREENSHOT_LANGUAGE"]

        if let envIndex, let idx = Int(envIndex) {
            return (idx, envLang ?? Locale.current.language.languageCode?.identifier ?? "ja")
        }

        #if os(macOS)
        if let data = try? Data(contentsOf: URL(fileURLWithPath: "/tmp/slidysshare_screenshot_config.json")),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            let idx = json["index"] as? Int ?? 0
            let lang = json["language"] as? String ?? "ja"
            return (idx, lang)
        }
        #endif

        return (0, Locale.current.language.languageCode?.identifier ?? "ja")
    }

    init() {
        let (index, languageCode) = Self.readConfig()

        guard let url = Bundle.main.url(forResource: "slidys-share-screenshots", withExtension: "json"),
              let jsonConfig = try? ScreenshotJSONConfig.load(from: url),
              index < jsonConfig.screenshots.count else {
            logger.error("[SlidysShareScreenshots] Failed to load JSON config index=\(index)")
            self.screenshotData = nil
            return
        }

        let definition = jsonConfig.screenshots[index]

        #if os(iOS)
        let platform: TargetPlatform = UIDevice.current.userInterfaceIdiom == .pad ? .iPadOS : .iOS
        #elseif os(macOS)
        let platform = TargetPlatform.macOS
        #elseif os(visionOS)
        let platform = TargetPlatform.visionOS
        #endif

        guard let config = AppStoreScreenshotConfig.from(
            definition: definition,
            languageCode: languageCode,
            targetPlatform: platform
        ) else {
            logger.error("[SlidysShareScreenshots] Failed to build AppStoreScreenshotConfig")
            self.screenshotData = nil
            return
        }

        logger.info("[SlidysShareScreenshots] index=\(index) state=\(definition.previewState) lang=\(languageCode)")

        self.screenshotData = ScreenshotData(
            config: config,
            previewState: definition.previewState
        )
    }

    var body: some Scene {
        WindowGroup {
            if let screenshotData {
                #if os(visionOS)
                screenshotScene(for: screenshotData.previewState)
                #elseif os(macOS)
                AppStorePreviewView(config: screenshotData.config) {
                    screenshotScene(for: screenshotData.previewState)
                }
                .onAppear {
                    NSApplication.shared.activate(ignoringOtherApps: true)
                    guard let window = NSApplication.shared.windows.first else { return }
                    window.styleMask = [.borderless]
                    window.setFrame(NSRect(
                        x: window.frame.origin.x,
                        y: window.frame.origin.y,
                        width: 1280,
                        height: 800
                    ), display: true)
                    window.makeKeyAndOrderFront(nil)
                }
                #else
                AppStorePreviewView(config: screenshotData.config) {
                    screenshotScene(for: screenshotData.previewState)
                }
                .statusBarHidden()
                #endif
            } else {
                Text("Failed to load screenshot config")
            }
        }
        #if os(visionOS)
        .defaultSize(width: 1400, height: 900)
        #elseif os(macOS)
        .defaultSize(width: 1280, height: 800)
        #endif
    }
}

private struct ScreenshotData: Sendable {
    let config: AppStoreScreenshotConfig
    let previewState: String
}
