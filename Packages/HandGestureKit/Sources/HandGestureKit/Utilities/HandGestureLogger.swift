//
//  HandGestureLogger.swift
//  HandGesturePackage
//
//  Created by Assistant on 2024/12/10.
//

import Foundation
import os

/// ハンドジェスチャーパッケージのロガー
public enum HandGestureLogger {
    
    // MARK: - Debug Control
    
    /// デバッグログ出力を制御する単一のフラグ
    public static var isDebugEnabled = true
    
    // MARK: - Logger Categories
    
    /// システム関連のログ
    public static let system = Logger(subsystem: "com.handgesture.package", category: "system")
    
    /// ジェスチャー検出関連のログ
    public static let gesture = Logger(subsystem: "com.handgesture.package", category: "gesture")
    
    /// パフォーマンス関連のログ
    public static let performance = Logger(subsystem: "com.handgesture.package", category: "performance")
    
    /// UI関連のログ
    public static let ui = Logger(subsystem: "com.handgesture.package", category: "ui")
    
    /// デバッグ用のログ
    public static let debug = Logger(subsystem: "com.handgesture.package", category: "debug")
    
    // MARK: - Configuration
    
    /// ログ出力設定
    public struct Configuration {
        /// システムログを出力するか
        public var enableSystemLogs = true
        
        /// ジェスチャー検出ログを出力するか
        public var enableGestureLogs = true
        
        /// パフォーマンスログを出力するか
        public var enablePerformanceLogs = true
        
        /// UIログを出力するか
        public var enableUILogs = true
        
        /// デバッグログを出力するか
        public var enableDebugLogs = true
        
        /// すべてのログを無効化
        public mutating func disableAll() {
            enableSystemLogs = false
            enableGestureLogs = false
            enablePerformanceLogs = false
            enableUILogs = false
            enableDebugLogs = false
        }
        
        /// すべてのログを有効化
        public mutating func enableAll() {
            enableSystemLogs = true
            enableGestureLogs = true
            enablePerformanceLogs = true
            enableUILogs = true
            enableDebugLogs = true
        }
    }
    
    /// 現在のログ設定
    public static var configuration = Configuration() {
        didSet {
            // isDebugEnabledフラグと同期
            configuration.enableDebugLogs = isDebugEnabled
        }
    }
    
    // MARK: - Convenience Methods
    
    /// システムログを出力
    public static func logSystem(_ message: String, type: OSLogType = .info) {
        guard configuration.enableSystemLogs else { return }
        system.log(level: type, "\(message)")
    }
    
    /// ジェスチャー検出ログを出力
    public static func logGesture(_ message: String, type: OSLogType = .info) {
        guard configuration.enableGestureLogs else { return }
        gesture.log(level: type, "\(message)")
    }
    
    /// パフォーマンスログを出力
    public static func logPerformance(_ message: String, type: OSLogType = .info) {
        guard configuration.enablePerformanceLogs else { return }
        performance.log(level: type, "\(message)")
    }
    
    /// UIログを出力
    public static func logUI(_ message: String, type: OSLogType = .info) {
        guard configuration.enableUILogs else { return }
        ui.log(level: type, "\(message)")
    }
    
    /// デバッグログを出力
    public static func logDebug(_ message: String, type: OSLogType = .debug) {
        guard isDebugEnabled else { return }
        debug.log(level: type, "\(message)")
    }
    
    /// エラーログを出力（常に出力）
    public static func logError(_ message: String, error: Error? = nil) {
        if let error = error {
            system.error("❌ \(message): \(error.localizedDescription)")
        } else {
            system.error("❌ \(message)")
        }
    }
}