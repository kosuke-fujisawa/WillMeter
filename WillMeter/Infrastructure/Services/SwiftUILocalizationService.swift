//
// SwiftUILocalizationService.swift
// WillMeter
//
// Created by WillMeter Project
// Licensed under CC BY-NC 4.0
// https://creativecommons.org/licenses/by-nc/4.0/
//

import Foundation
import OSLog
import SwiftUI

/// SwiftUI環境でのローカライズと変更通知を提供する
public final class SwiftUILocalizationService: ObservableObject {
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "WillMeter", category: "Localization")

    /// 言語変更通知用Publisher
    @Published public private(set) var currentLanguageCode: String

    /// ユーザーが手動設定した言語（UserDefaults保存）
    private static let selectedLanguageKey = "selected_language"

    /// サポート言語の表示順と表示名を一元管理する
    private static let supportedLanguageDefinitions: [(code: String, name: String)] = [
        (code: "ja", name: "日本語"),
        (code: "en", name: "English"),
        (code: "zh-Hans", name: "简体中文")
    ]
    public static let supportedLanguages = supportedLanguageDefinitions.map(\.code)
    public static let languageDisplayNames = Dictionary(
        uniqueKeysWithValues: supportedLanguageDefinitions.map { ($0.code, $0.name) }
    )

    public init() {
        // 保存された言語設定を復元、未設定時はシステム言語
        if let savedLanguage = UserDefaults.standard.string(forKey: Self.selectedLanguageKey),
           Self.supportedLanguages.contains(savedLanguage) {
            self.currentLanguageCode = savedLanguage
        } else {
            // システム言語からサポート言語を選択
            let preferredLanguages = Locale.preferredLanguages
            self.currentLanguageCode = Self.selectSupportedLanguage(from: preferredLanguages)
        }
    }

    /// 指定されたキーの翻訳文字列を取得
    public func localizedString(for key: String) -> String {
        // Bundle.main から指定言語のリソースを取得
        guard let path = Bundle.main.path(forResource: currentLanguageCode, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return self.localizedString(for: key, fallbackLanguage: "ja")
        }

        // 意図的に動的キーを使用（LocalizationKeysで型安全性を確保）
        // swiftlint:disable:next nslocalizedstring_key
        let localizedString = NSLocalizedString(key, bundle: bundle, comment: "")

        // キーがそのまま返された場合はフォールバック
        if localizedString == key {
            return self.localizedString(for: key, fallbackLanguage: "ja")
        }

        return localizedString
    }

    /// 複数形対応の翻訳文字列取得
    public func localizedString(for key: String, count: Int) -> String {
        let pluralKey = count == 1 ? "\(key).singular" : "\(key).plural"
        let pluralString = localizedString(for: pluralKey)

        // 複数形キーが見つからない場合は通常キーを使用
        if pluralString == pluralKey {
            return String.localizedStringWithFormat(localizedString(for: key), count)
        }

        return String.localizedStringWithFormat(pluralString, count)
    }

    /// フォーマット引数を伴う翻訳文字列取得（%d等のプレースホルダーを実際の値に置換）
    public func localizedString(for key: String, arguments: CVarArg...) -> String {
        String(
            format: localizedString(for: key),
            locale: Locale(identifier: currentLanguageCode),
            arguments: arguments
        )
    }

    /// 言語を動的に変更
    /// - Parameter languageCode: 変更先の言語コード
    public func changeLanguage(to languageCode: String) {
        guard Self.supportedLanguages.contains(languageCode) else {
            Self.logger.warning("Unsupported language: \(languageCode, privacy: .public)")
            return
        }

        currentLanguageCode = languageCode
        UserDefaults.standard.set(languageCode, forKey: Self.selectedLanguageKey)

        // 言語変更をUI層に通知（メインスレッドで実行）
        DispatchQueue.main.async { [weak self] in
            self?.objectWillChange.send()
        }
    }

    /// フォールバック言語での文字列取得
    private func localizedString(for key: String, fallbackLanguage: String) -> String {
        guard let path = Bundle.main.path(forResource: fallbackLanguage, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return key // 最終フォールバック
        }

        // フォールバック処理での動的キー使用（設計上必要）
        // swiftlint:disable:next nslocalizedstring_key
        let fallbackString = NSLocalizedString(key, bundle: bundle, comment: "")
        return fallbackString == key ? key : fallbackString
    }

    /// システム言語からサポート言語を選択
    private static func selectSupportedLanguage(from preferredLanguages: [String]) -> String {
        let supportedSet = Set(supportedLanguages)

        for preferred in preferredLanguages {
            // 完全一致チェック
            if supportedSet.contains(preferred) {
                return preferred
            }

            // 言語コードのみ抽出してチェック（例: "ja-JP" → "ja"）
            let languageCode = String(preferred.prefix(2))
            if supportedSet.contains(languageCode) {
                return languageCode
            }

            // 中国語の特別処理
            if preferred.hasPrefix("zh") {
                if preferred.contains("Hans") || preferred.contains("CN") || preferred.contains("SG") {
                    return "zh-Hans"
                }
            }
        }

        // デフォルトは日本語
        return "ja"
    }
}

/// SwiftUI環境での便利な拡張
public extension SwiftUILocalizationService {
    /// 現在の言語表示名を取得
    var currentLanguageDisplayName: String {
        Self.languageDisplayNames[currentLanguageCode] ?? currentLanguageCode
    }

    /// 全サポート言語の表示名を取得
    var supportedLanguagesDisplayNames: [(code: String, name: String)] {
        Self.supportedLanguageDefinitions
    }
}
