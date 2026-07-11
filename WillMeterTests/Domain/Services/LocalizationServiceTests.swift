//
// LocalizationServiceTests.swift
// WillMeterTests
//
// Created by WillMeter Project
// Licensed under CC BY-NC 4.0
// https://creativecommons.org/licenses/by-nc/4.0/
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
            XCTAssertTrue(key.hasPrefix("willpower."), "Key should start with 'willpower.' prefix")
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
            XCTAssertTrue(key.hasPrefix("willpower.status."), "Status key should start with 'willpower.status.' prefix")
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
            XCTAssertTrue(key.hasPrefix("willpower.action."), "Action key should start with 'willpower.action.' prefix")
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
            XCTAssertTrue(key.hasPrefix("ui."), "UI key should start with 'ui.' prefix")
        }
    }

    func testLocalizationKeys_UIAccessibility_shouldHaveAllRequiredKeys() {
        // Given & When: アクセシビリティキー群
        let accessibilityKeys = [
            LocalizationKeys.UI.Accessibility.consumeHint,
            LocalizationKeys.UI.Accessibility.restoreHint,
            LocalizationKeys.UI.Accessibility.resetHint,
            LocalizationKeys.UI.Accessibility.languageButton,
            LocalizationKeys.UI.Accessibility.languageButtonHint
        ]

        // Then: 全アクセシビリティキーが定義されている
        for key in accessibilityKeys {
            XCTAssertFalse(key.isEmpty, "Accessibility key should not be empty")
            XCTAssertTrue(
                key.hasPrefix("ui.accessibility."),
                "Accessibility key should start with 'ui.accessibility.' prefix"
            )
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
            XCTAssertTrue(
                key.hasPrefix("recommendation."),
                "Recommendation key should start with 'recommendation.' prefix"
            )
        }
    }

    // MARK: - キー命名規則テスト

    func testLocalizationKeys_shouldFollowHierarchicalNaming() throws {
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
            let regex = try NSRegularExpression(pattern: testCase.expectedPattern)
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
            LocalizationKeys.UI.Accessibility.languageButton,
            LocalizationKeys.UI.Accessibility.languageButtonHint,

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
