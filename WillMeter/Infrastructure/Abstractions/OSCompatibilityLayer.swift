//
// OSCompatibilityLayer.swift
// WillMeter
//
// Created by WillMeter Project
// Licensed under CC BY-NC 4.0
// https://creativecommons.org/licenses/by-nc/4.0/
//

import Foundation
import SwiftUI

/// OSバージョン間の互換性を提供する抽象化層
/// アップデートによる破壊的変更の影響を最小化する
public struct OSCompatibilityLayer {
    // MARK: - iOS Version Detection

    /// 現在のiOSバージョンが指定バージョン以上かを判定
    /// - Parameter version: 比較対象のiOSバージョン（例: "19.0"）
    /// - Returns: 指定バージョン以上の場合true
    public static func isAvailable(_ version: String) -> Bool {
        guard let targetVersion = parseVersion(version) else {
            return false
        }

        let systemVersion = UIDevice.current.systemVersion
        guard let currentVersion = parseVersion(systemVersion) else {
            return false
        }

        return compareVersions(currentVersion, targetVersion)
    }

    /// バージョン文字列を数値配列に変換する補助メソッド
    /// - Parameter version: バージョン文字列（例: "18.5.2"）
    /// - Returns: 比較可能な数値配列（例: [18, 5, 2]）
    private static func parseVersion(_ version: String) -> [Int]? {
        let components = version.split(separator: ".").compactMap { Int($0) }
        guard !components.isEmpty else {
            return nil
        }
        return components
    }

    /// バージョン配列を比較する補助メソッド
    /// - Parameters:
    ///   - current: 現在のバージョン配列
    ///   - target: 対象バージョン配列
    /// - Returns: current >= target の場合true
    private static func compareVersions(_ current: [Int], _ target: [Int]) -> Bool {
        let maxLength = max(current.count, target.count)

        for index in 0..<maxLength {
            let currentComponent = index < current.count ? current[index] : 0
            let targetComponent = index < target.count ? target[index] : 0

            if currentComponent > targetComponent {
                return true
            } else if currentComponent < targetComponent {
                return false
            }
        }

        return true // 完全一致の場合はtrue
    }

    // MARK: - SwiftUI Compatibility

    /// バージョン別のナビゲーション実装
    /// iOS 19で変更される可能性のあるNavigationStack対応
    @ViewBuilder
    public static func compatibleNavigationStack<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        if #available(iOS 19.0, *) {
            // TODO: iOS 19での新しいNavigation実装に置き換える
            // 将来のiOS 19での新しいNavigation実装
            NavigationStack {
                content()
            }
        } else {
            // iOS 18.5での既存実装
            NavigationStack {
                content()
            }
        }
    }

    /// 互換性のあるColor実装
    /// システムカラーの変更に対応
    public static func compatibleSystemColor(_ colorName: String) -> Color {
        if #available(iOS 19.0, *) {
            // iOS 19で新しいシステムカラーが追加される場合の対応
            switch colorName {
            case "primary":
                return .primary
            case "secondary":
                return .secondary
            default:
                return .blue
            }
        } else {
            // iOS 18.5での既存カラー
            switch colorName {
            case "primary":
                return .primary
            case "secondary":
                return .secondary
            default:
                return .blue
            }
        }
    }

    // MARK: - UserDefaults Compatibility

    /// 互換性のあるUserDefaults操作
    /// キー名の変更や型の変更に対応
    public struct CompatibleUserDefaults {
        private static let userDefaults = UserDefaults.standard

        /// WillPowerデータの保存
        /// - Parameters:
        ///   - currentValue: 現在の意思力値
        ///   - maxValue: 最大意思力値
        public static func saveWillPower(currentValue: Int, maxValue: Int) {
            // iOS 19で新しいキー体系が必要になった場合の対応準備
            let key = "willpower_data_v1"
            let data = ["current": currentValue, "max": maxValue]

            if let encoded = try? JSONEncoder().encode(data) {
                userDefaults.set(encoded, forKey: key)
            }
        }

        /// WillPowerデータの読み込み
        /// - Returns: (currentValue: Int, maxValue: Int)のタプル
        public static func loadWillPower() -> (current: Int, max: Int)? {
            let key = "willpower_data_v1"

            guard let data = userDefaults.data(forKey: key),
                  let decoded = try? JSONDecoder().decode([String: Int].self, from: data),
                  let current = decoded["current"],
                  let max = decoded["max"] else {
                // フォールバック: 旧形式のデータ読み込み
                return loadLegacyWillPower()
            }

            return (current: current, max: max)
        }

        /// 旧形式のWillPowerデータ読み込み（移行用）
        private static func loadLegacyWillPower() -> (current: Int, max: Int)? {
            let currentKey = "current_willpower"
            let maxKey = "max_willpower"

            if userDefaults.object(forKey: currentKey) != nil {
                let current = userDefaults.integer(forKey: currentKey)
                let max = userDefaults.integer(forKey: maxKey)
                return (current: current, max: max)
            }

            return nil
        }
    }

    // MARK: - Performance Optimization

    /// OSバージョンに最適化されたパフォーマンス設定
    public struct PerformanceSettings {
        /// アニメーション時間の最適化
        public static var animationDuration: Double {
            if #available(iOS 19.0, *) {
                // iOS 19で推奨されるアニメーション時間
                return 0.25
            } else {
                // iOS 18.5での標準アニメーション時間
                return 0.3
            }
        }

        /// UI更新の最適化設定
        public static var uiUpdateThrottle: TimeInterval {
            if #available(iOS 19.0, *) {
                // iOS 19での最適化された更新間隔
                return 1.0 / 120.0 // 120Hz対応
            } else {
                // iOS 18.5での標準更新間隔
                return 1.0 / 60.0  // 60Hz
            }
        }
    }

    // MARK: - Feature Flags

    /// 機能フラグによる段階的機能提供
    public struct FeatureFlags {
        /// 新しいUI機能の有効性
        public static var newUIEnabled: Bool {
            return isAvailable("19.0")
        }

        /// 高度なアニメーション機能
        public static var advancedAnimationsEnabled: Bool {
            return isAvailable("19.0")
        }

        /// パフォーマンス監視機能
        public static var performanceMonitoringEnabled: Bool {
            return isAvailable("18.5")
        }
    }

    // MARK: - Migration Support

    /// データ移行サポート
    public struct MigrationSupport {
        /// アプリバージョンの取得
        public static var currentAppVersion: String {
            return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        }

        /// OSバージョンの取得
        public static var currentOSVersion: String {
            return UIDevice.current.systemVersion
        }

        /// 移行が必要かの判定
        /// - Parameter fromVersion: 移行元バージョン
        /// - Returns: 移行が必要な場合true
        public static func needsMigration(fromVersion: String) -> Bool {
            return currentAppVersion != fromVersion
        }
    }
}

// MARK: - Extensions

public extension OSCompatibilityLayer {
    /// ログ出力の互換性ラッパー
    static func compatibleLog(_ message: String, category: String = "WillMeter") {
        if #available(iOS 19.0, *) {
            // TODO: os.Loggerなど新しいログシステムへの移行
            // iOS 19での新しいロギング方式
            print("[\(category)] \(message)")
        } else {
            // iOS 18.5での既存ロギング
            print("[\(category)] \(message)")
        }
    }
}
