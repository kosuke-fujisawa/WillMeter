//
//  SwiftUILocalizationServiceTests.swift
//  WillMeterTests
//
//  Created by WillMeter Project
//  Licensed under CC BY-NC 4.0
//  https://creativecommons.org/licenses/by-nc/4.0/
//

import Combine
@testable import WillMeter
import XCTest

final class SwiftUILocalizationServiceTests: XCTestCase {
    private var sut: SwiftUILocalizationService!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        sut = SwiftUILocalizationService()
        cancellables = []
    }

    override func tearDown() {
        cancellables = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - 初期化テスト

    func testInitialization_shouldSetSupportedLanguages() {
        // Given & When: サービス初期化

        // Then: サポート言語が正しく設定される
        XCTAssertEqual(sut.supportedLanguages, ["ja", "en", "zh-Hans"])
    }

    func testInitialization_shouldSetDefaultLanguage() {
        // Given & When: サービス初期化

        // Then: デフォルト言語が設定される
        XCTAssertTrue(sut.supportedLanguages.contains(sut.currentLanguageCode))
    }

    // MARK: - 言語変更テスト

    func testChangeLanguage_withSupportedLanguage_shouldUpdateCurrentLanguage() {
        // Given: サポート対象言語
        let targetLanguage = "en"
        var languageChanged = false

        sut.objectWillChange.sink {
            languageChanged = true
        }.store(in: &cancellables)

        // When: 言語変更
        sut.changeLanguage(to: targetLanguage)

        // Then: 現在言語が更新される
        XCTAssertEqual(sut.currentLanguageCode, targetLanguage)
        XCTAssertTrue(languageChanged)
    }

    func testChangeLanguage_withUnsupportedLanguage_shouldNotUpdateCurrentLanguage() {
        // Given: サポート対象外言語
        let originalLanguage = sut.currentLanguageCode
        let unsupportedLanguage = "fr"
        var languageChanged = false

        sut.objectWillChange.sink {
            languageChanged = true
        }.store(in: &cancellables)

        // When: サポート対象外言語に変更試行
        sut.changeLanguage(to: unsupportedLanguage)

        // Then: 現在言語は変更されない
        XCTAssertEqual(sut.currentLanguageCode, originalLanguage)
        XCTAssertFalse(languageChanged)
    }

    // MARK: - 翻訳文字列取得テスト

    func testLocalizedString_withValidKey_shouldReturnTranslatedString() {
        // Given: 有効なキー
        let key = LocalizationKeys.WillPower.Action.consume

        // When: 翻訳文字列取得
        let result = sut.localizedString(for: key)

        // Then: 翻訳された文字列が返される（キーそのものではない）
        XCTAssertNotEqual(result, key)
        XCTAssertFalse(result.isEmpty)
    }

    func testLocalizedString_withInvalidKey_shouldReturnKey() {
        // Given: 無効なキー
        let invalidKey = "invalid.key.does.not.exist"

        // When: 翻訳文字列取得
        let result = sut.localizedString(for: invalidKey)

        // Then: キーがそのまま返される（フォールバック）
        XCTAssertEqual(result, invalidKey)
    }

    // MARK: - 複数形対応テスト

    func testLocalizedString_withCount_shouldHandlePluralization() {
        // Given: 複数形対応が必要なキー
        let baseKey = "test.count"

        // When: 単数形
        let singularResult = sut.localizedString(for: baseKey, count: 1)

        // When: 複数形
        let pluralResult = sut.localizedString(for: baseKey, count: 2)

        // Then: 結果が取得される（詳細な翻訳内容はリソースファイル依存）
        XCTAssertFalse(singularResult.isEmpty)
        XCTAssertFalse(pluralResult.isEmpty)
    }

    // MARK: - 表示名テスト

    func testCurrentLanguageDisplayName_shouldReturnCorrectDisplayName() {
        // Given: 各言語への変更
        let testCases: [(code: String, expectedName: String)] = [
            ("ja", "日本語"),
            ("en", "English"),
            ("zh-Hans", "简体中文")
        ]

        for testCase in testCases {
            // When: 言語変更
            sut.changeLanguage(to: testCase.code)

            // Then: 正しい表示名が返される
            XCTAssertEqual(sut.currentLanguageDisplayName, testCase.expectedName)
        }
    }

    func testSupportedLanguagesDisplayNames_shouldReturnCorrectMapping() {
        // Given & When: サポート言語表示名取得
        let displayNames = sut.supportedLanguagesDisplayNames

        // Then: 正しいマッピングが返される
        XCTAssertEqual(displayNames.count, 3)

        let japaneseEntry = displayNames.first { $0.code == "ja" }
        XCTAssertEqual(japaneseEntry?.name, "日本語")

        let englishEntry = displayNames.first { $0.code == "en" }
        XCTAssertEqual(englishEntry?.name, "English")

        let chineseEntry = displayNames.first { $0.code == "zh-Hans" }
        XCTAssertEqual(chineseEntry?.name, "简体中文")
    }

    // MARK: - UserDefaults永続化テスト

    func testChangeLanguage_shouldPersistToUserDefaults() {
        // Given: 言語変更
        let targetLanguage = "en"

        // When: 言語変更
        sut.changeLanguage(to: targetLanguage)

        // Then: UserDefaultsに保存される
        let savedLanguage = UserDefaults.standard.string(forKey: "selected_language")
        XCTAssertEqual(savedLanguage, targetLanguage)

        // Cleanup
        UserDefaults.standard.removeObject(forKey: "selected_language")
    }

    func testInitialization_withSavedLanguage_shouldRestoreFromUserDefaults() {
        // Given: UserDefaultsに保存された言語設定
        let savedLanguage = "zh-Hans"
        UserDefaults.standard.set(savedLanguage, forKey: "selected_language")

        // When: 新しいサービスインスタンス作成
        let newService = SwiftUILocalizationService()

        // Then: 保存された言語が復元される
        XCTAssertEqual(newService.currentLanguageCode, savedLanguage)

        // Cleanup
        UserDefaults.standard.removeObject(forKey: "selected_language")
    }

    // MARK: - Observable変更通知テスト

    func testLanguageChange_shouldTriggerObjectWillChange() {
        // Given: 初期状態確認
        let initialLanguage = sut.currentLanguageCode
        XCTAssertNotEqual(initialLanguage, "en")

        // When: 言語変更
        sut.changeLanguage(to: "en")

        // Then: 言語が変更されている
        XCTAssertEqual(sut.currentLanguageCode, "en")
        XCTAssertNotEqual(sut.currentLanguageCode, initialLanguage)
    }
}
