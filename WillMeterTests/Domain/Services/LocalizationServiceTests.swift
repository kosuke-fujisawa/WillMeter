//
//  LocalizationServiceTests.swift
//  WillMeterTests
//
//  Created by WillMeter Project
//  Licensed under CC BY-NC 4.0
//  https://creativecommons.org/licenses/by-nc/4.0/
//

@testable import WillMeter
import XCTest

final class LocalizationServiceTests: XCTestCase {
    // MARK: - LocalizationKeysテスト

    func testLocalizationKeys_WillPower_shouldHaveAllRequiredKeys() {
        // Given & When: WillPowerキー群
        let keys = [
            LocalizationKeys.WillPower.title,
            LocalizationKeys.WillPower.currentValue,
            LocalizationKeys.WillPower.maxValue,
            LocalizationKeys.WillPower.percentage
        ]

        // Then: 全キーが定義されている
        for key in keys {
            XCTAssertFalse(key.isEmpty, "Key should not be empty")
            XCTAssertTrue(key.contains("willpower"), "Key should contain 'willpower' prefix")
        }
    }

    func testLocalizationKeys_WillPowerStatus_shouldHaveAllRequiredKeys() {
        // Given & When: WillPowerステータスキー群
        let statusKeys = [
            LocalizationKeys.WillPower.Status.excellent,
            LocalizationKeys.WillPower.Status.good,
            LocalizationKeys.WillPower.Status.normal,
            LocalizationKeys.WillPower.Status.low,
            LocalizationKeys.WillPower.Status.critical
        ]

        // Then: 全ステータスキーが定義されている
        for key in statusKeys {
            XCTAssertFalse(key.isEmpty, "Status key should not be empty")
            XCTAssertTrue(key.contains("willpower.status"), "Status key should contain 'willpower.status' prefix")
        }
    }

    func testLocalizationKeys_WillPowerAction_shouldHaveAllRequiredKeys() {
        // Given & When: WillPowerアクションキー群
        let actionKeys = [
            LocalizationKeys.WillPower.Action.consume,
            LocalizationKeys.WillPower.Action.restore,
            LocalizationKeys.WillPower.Action.reset
        ]

        // Then: 全アクションキーが定義されている
        for key in actionKeys {
            XCTAssertFalse(key.isEmpty, "Action key should not be empty")
            XCTAssertTrue(key.contains("willpower.action"), "Action key should contain 'willpower.action' prefix")
        }
    }

    func testLocalizationKeys_UI_shouldHaveAllRequiredKeys() {
        // Given & When: UIキー群
        let uiKeys = [
            LocalizationKeys.UI.appTitle,
            LocalizationKeys.UI.currentState
        ]

        // Then: 全UIキーが定義されている
        for key in uiKeys {
            XCTAssertFalse(key.isEmpty, "UI key should not be empty")
            XCTAssertTrue(key.contains("ui"), "UI key should contain 'ui' prefix")
        }
    }

    func testLocalizationKeys_UIAccessibility_shouldHaveAllRequiredKeys() {
        // Given & When: アクセシビリティキー群
        let accessibilityKeys = [
            LocalizationKeys.UI.Accessibility.consumeHint,
            LocalizationKeys.UI.Accessibility.restoreHint,
            LocalizationKeys.UI.Accessibility.resetHint
        ]

        // Then: 全アクセシビリティキーが定義されている
        for key in accessibilityKeys {
            XCTAssertFalse(key.isEmpty, "Accessibility key should not be empty")
            XCTAssertTrue(key.contains("ui.accessibility"), "Accessibility key should contain 'ui.accessibility' prefix")
        }
    }

    func testLocalizationKeys_Recommendation_shouldHaveAllRequiredKeys() {
        // Given & When: 推奨アクションキー群
        let recommendationKeys = [
            LocalizationKeys.Recommendation.excellent,
            LocalizationKeys.Recommendation.good,
            LocalizationKeys.Recommendation.normal,
            LocalizationKeys.Recommendation.low,
            LocalizationKeys.Recommendation.critical
        ]

        // Then: 全推奨アクションキーが定義されている
        for key in recommendationKeys {
            XCTAssertFalse(key.isEmpty, "Recommendation key should not be empty")
            XCTAssertTrue(key.contains("recommendation"), "Recommendation key should contain 'recommendation' prefix")
        }
    }

    // MARK: - キー命名規則テスト

    func testLocalizationKeys_shouldFollowHierarchicalNaming() {
        // Given: 階層的命名規則のテストケース
        let testCases: [(key: String, expectedPattern: String)] = [
            (LocalizationKeys.WillPower.title, "^willpower\\.[a-z]+$"),
            (LocalizationKeys.WillPower.Status.excellent, "^willpower\\.status\\.[a-z]+$"),
            (LocalizationKeys.WillPower.Action.consume, "^willpower\\.action\\.[a-z]+$"),
            (LocalizationKeys.UI.appTitle, "^ui\\.[a-z]+\\.[a-z]+$"),
            (LocalizationKeys.UI.Accessibility.consumeHint, "^ui\\.accessibility\\.[a-z]+\\.[a-z]+$"),
            (LocalizationKeys.Recommendation.excellent, "^recommendation\\.[a-z]+$")
        ]

        for testCase in testCases {
            // When & Then: 正規表現パターンマッチング
            let regex = try! NSRegularExpression(pattern: testCase.expectedPattern)
            let range = NSRange(location: 0, length: testCase.key.utf16.count)
            let matches = regex.numberOfMatches(in: testCase.key, options: [], range: range)

            XCTAssertEqual(matches, 1, "Key '\(testCase.key)' should match pattern '\(testCase.expectedPattern)'")
        }
    }

    // MARK: - キー重複チェックテスト

    func testLocalizationKeys_shouldNotHaveDuplicateKeys() {
        // Given: 全キーの収集
        let allKeys = [
            // WillPower keys
            LocalizationKeys.WillPower.title,
            LocalizationKeys.WillPower.currentValue,
            LocalizationKeys.WillPower.maxValue,
            LocalizationKeys.WillPower.percentage,

            // Status keys
            LocalizationKeys.WillPower.Status.excellent,
            LocalizationKeys.WillPower.Status.good,
            LocalizationKeys.WillPower.Status.normal,
            LocalizationKeys.WillPower.Status.low,
            LocalizationKeys.WillPower.Status.critical,

            // Action keys
            LocalizationKeys.WillPower.Action.consume,
            LocalizationKeys.WillPower.Action.restore,
            LocalizationKeys.WillPower.Action.reset,

            // UI keys
            LocalizationKeys.UI.appTitle,
            LocalizationKeys.UI.currentState,

            // Accessibility keys
            LocalizationKeys.UI.Accessibility.consumeHint,
            LocalizationKeys.UI.Accessibility.restoreHint,
            LocalizationKeys.UI.Accessibility.resetHint,

            // Recommendation keys
            LocalizationKeys.Recommendation.excellent,
            LocalizationKeys.Recommendation.good,
            LocalizationKeys.Recommendation.normal,
            LocalizationKeys.Recommendation.low,
            LocalizationKeys.Recommendation.critical
        ]

        // When: 重複チェック
        let uniqueKeys = Set(allKeys)

        // Then: 重複なし
        XCTAssertEqual(allKeys.count, uniqueKeys.count, "All localization keys should be unique")
    }
}

// MARK: - Mock LocalizationService

/// テスト用のモックLocalizationService実装
class MockLocalizationService: LocalizationService {
    var currentLanguageCode: String
    let supportedLanguages: [String] = ["ja", "en", "zh-Hans"]

    private let mockTranslations: [String: [String: String]] = [
        "ja": [
            "test.key": "テストキー",
            "willpower.title": "意志力",
            "willpower.status.excellent": "最高"
        ],
        "en": [
            "test.key": "Test Key",
            "willpower.title": "Willpower",
            "willpower.status.excellent": "Excellent"
        ],
        "zh-Hans": [
            "test.key": "测试键",
            "willpower.title": "意志力",
            "willpower.status.excellent": "优秀"
        ]
    ]

    init(initialLanguage: String = "ja") {
        self.currentLanguageCode = initialLanguage
    }

    func localizedString(for key: String) -> String {
        return mockTranslations[currentLanguageCode]?[key] ?? key
    }

    func localizedString(for key: String, count: Int) -> String {
        let pluralKey = count == 1 ? "\(key).singular" : "\(key).plural"
        return localizedString(for: pluralKey)
    }

    func changeLanguage(to languageCode: String) {
        if supportedLanguages.contains(languageCode) {
            currentLanguageCode = languageCode
        }
    }
}
