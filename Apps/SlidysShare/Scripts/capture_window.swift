#!/usr/bin/env swift
// Captures a macOS window by owner name prefix and saves as PNG.
// Finds the main content window (640x400) and uses screencapture -l to capture it.
// Usage: swift capture_window.swift <name_prefix> <output_path>

import AppKit

guard CommandLine.arguments.count >= 3 else {
    fputs("Usage: capture_window.swift <name_prefix> <output_path>\n", stderr)
    exit(1)
}

let namePrefix = CommandLine.arguments[1]
let outputPath = CommandLine.arguments[2]

// Find window ID using CGWindowListCopyWindowInfo
guard let windowList = CGWindowListCopyWindowInfo([.optionAll, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]] else {
    fputs("Error: Failed to get window list\n", stderr)
    exit(1)
}

// Find the main content window (640x400) for the app
var targetWindowID: CGWindowID? = nil
var fallbackWindowID: CGWindowID? = nil
var fallbackArea: CGFloat = 0

for window in windowList {
    guard let ownerName = window[kCGWindowOwnerName as String] as? String,
          ownerName.hasPrefix(namePrefix),
          let windowID = window[kCGWindowNumber as String] as? CGWindowID,
          let bounds = window[kCGWindowBounds as String] as? [String: Any],
          let width = bounds["Width"] as? CGFloat,
          let height = bounds["Height"] as? CGFloat,
          width > 0, height > 0 else {
        continue
    }

    let layer = window[kCGWindowLayer as String] as? Int ?? 999

    // Skip menu bar windows (layer != 0 or height <= 40)
    if layer != 0 || height <= 40 {
        continue
    }

    // Prefer the 1280x800 window (our target size)
    if abs(width - 1280) < 10 && abs(height - 800) < 10 {
        targetWindowID = windowID
        break
    }

    // Track the largest on-screen window as fallback
    let area = width * height
    if area > fallbackArea {
        fallbackArea = area
        fallbackWindowID = windowID
    }
}

guard let windowID = targetWindowID ?? fallbackWindowID else {
    fputs("Error: No window found with prefix '\(namePrefix)'\n", stderr)
    exit(1)
}

// Use screencapture -l to capture the window
let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
process.arguments = ["-l\(windowID)", "-x", outputPath]

do {
    try process.run()
    process.waitUntilExit()
    if process.terminationStatus != 0 {
        fputs("Error: screencapture failed with status \(process.terminationStatus)\n", stderr)
        exit(1)
    }
} catch {
    fputs("Error: \(error.localizedDescription)\n", stderr)
    exit(1)
}

// Resize to 1280x800 for App Store
let sips = Process()
sips.executableURL = URL(fileURLWithPath: "/usr/bin/sips")
sips.arguments = ["-z", "800", "1280", outputPath]
sips.standardOutput = FileHandle.nullDevice
sips.standardError = FileHandle.nullDevice
try? sips.run()
sips.waitUntilExit()
