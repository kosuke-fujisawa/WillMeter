//
//  LocalizationService.swift
//  WillMeter
//
//  Created by WillMeter Project
//  Licensed under CC BY-NC 4.0
//  https://creativecommons.org/licenses/by-nc/4.0/
//

import Foundation

/// ドメイン層での多言語化サービス抽象化
/// Clean Architecture原則に従い、UI技術に依存しない形で言語リソースアクセスを提供
public protocol LocalizationService {
    /// 指定されたキーに対応する翻訳済み文字列を取得
    /// - Parameter key: 翻訳文字列のキー（階層構造: "willpower.current.label"）
    /// - Returns: 現在の言語設定に基づく翻訳済み文字列
    func localizedString(for key: String) -> String

    /// 複数形対応の翻訳文字列取得
    /// - Parameters:
    ///   - key: 翻訳文字列のキー
    ///   - count: 数量（複数形判定用）
    /// - Returns: 数量に応じた適切な翻訳文字列
    func localizedString(for key: String, count: Int) -> String

    /// 現在設定されている言語コード取得
    /// - Returns: 言語コード（例: "ja", "en", "zh-Hans"）
    var currentLanguageCode: String { get }

    /// サポートされている言語コード一覧
    /// - Returns: 利用可能な言語コードの配列
    var supportedLanguages: [String] { get }
}

/// 多言語化キー定数
/// 階層的な命名規則によるタイプセーフなキー管理
public enum LocalizationKeys {
    public enum WillPower {
        public static let title = "willpower.title"
        public static let currentValue = "willpower.current.value"
        public static let maxValue = "willpower.max.value"
        public static let percentage = "willpower.percentage"

        public enum Status {
            public static let excellent = "willpower.status.excellent"
            public static let good = "willpower.status.good"
            public static let normal = "willpower.status.normal"
            public static let low = "willpower.status.low"
            public static let critical = "willpower.status.critical"
        }

        public enum Action {
            public static let consume = "willpower.action.consume"
            public static let restore = "willpower.action.restore"
            public static let reset = "willpower.action.reset"
        }
    }

    public enum UI {
        public static let appTitle = "ui.app.title"
        public static let currentState = "ui.current.state"

        public enum Accessibility {
            public static let consumeHint = "ui.accessibility.consume.hint"
            public static let restoreHint = "ui.accessibility.restore.hint"
            public static let resetHint = "ui.accessibility.reset.hint"
        }
    }

    public enum Recommendation {
        public static let excellent = "recommendation.excellent"
        public static let good = "recommendation.good"
        public static let normal = "recommendation.normal"
        public static let low = "recommendation.low"
        public static let critical = "recommendation.critical"
    }
}
