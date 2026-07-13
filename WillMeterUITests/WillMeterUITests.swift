import XCTest

final class WillMeterUITests: XCTestCase {

    override func setUpWithError() throws {
        // UIテストは失敗時に即座に停止する
        continueAfterFailure = false
    }

    /// オンボーディング画面が表示されていれば閉じる（未実装ブランチとの互換のため存在チェックのみ）
    @MainActor
    private func dismissOnboardingIfPresent(_ app: XCUIApplication) {
        let startButton = app.buttons["onboardingStartButton"]
        if startButton.waitForExistence(timeout: 2) {
            startButton.tap()
        }
    }

    /// sheet提示直後のアニメーション中はヒットテストが不安定なため、要素が確実にタップ可能になるまで
    /// 短い間隔で再タップを試みるヘルパー
    @MainActor
    private func tapUntilLabelMatches(
        _ element: XCUIElement,
        expectedLabel: String,
        on target: XCUIElement,
        attempts: Int = 3
    ) {
        for _ in 0..<attempts {
            if target.label == expectedLabel {
                return
            }
            element.tap()
            let predicate = NSPredicate(format: "label == %@", expectedLabel)
            let waitExpectation = XCTNSPredicateExpectation(predicate: predicate, object: target)
            _ = XCTWaiter().wait(for: [waitExpectation], timeout: 2)
        }
    }

    @MainActor
    func testConsumeRestoreResetFlow() throws {
        let app = XCUIApplication()
        app.launch()
        dismissOnboardingIfPresent(app)

        let resetButton = app.buttons["resetButton"]
        XCTAssertTrue(resetButton.waitForExistence(timeout: 5), "リセットボタンが表示されること")
        resetButton.tap()

        let valueText = app.staticTexts["willPowerCurrentValueText"]
        XCTAssertTrue(valueText.waitForExistence(timeout: 5), "現在値テキストが表示されること")
        XCTAssertEqual(valueText.label, "100", "リセット直後は最大値であること")

        let consumeButton = app.buttons["consumeButton"]
        XCTAssertTrue(consumeButton.exists, "消費ボタンが表示されること")
        consumeButton.tap()
        XCTAssertEqual(valueText.label, "80", "消費(20)後は80になること")

        let restoreButton = app.buttons["restoreButton"]
        XCTAssertTrue(restoreButton.exists, "回復ボタンが表示されること")
        restoreButton.tap()
        XCTAssertEqual(valueText.label, "100", "回復(+20)後は上限100で頭打ちになること")

        consumeButton.tap()
        consumeButton.tap()
        XCTAssertEqual(valueText.label, "60", "2回消費(20ずつ)後は60になること")

        resetButton.tap()
        XCTAssertEqual(valueText.label, "100", "リセット後は最大値に戻ること")
    }

    @MainActor
    func testLanguageSwitching() throws {
        let app = XCUIApplication()
        app.launch()
        dismissOnboardingIfPresent(app)

        let languageToggleButton = app.buttons["languageToggleButton"]
        XCTAssertTrue(languageToggleButton.waitForExistence(timeout: 5), "言語切替ボタンが表示されること")
        languageToggleButton.tap()

        let englishRow = app.buttons["languageRow_en"]
        XCTAssertTrue(englishRow.waitForExistence(timeout: 5), "英語の選択行が表示されること")

        // 言語設定画面内の「現在の言語」表示がEnglishに変わることを確認してから閉じる
        // (accessibilityIdentifierは言語に依存せず常に存在するため、labelの内容変化を待機する必要がある。
        //  sheet提示直後はアニメーション中でヒットテストが不安定なため再タップを試みる)
        let currentLanguageText = app.staticTexts["currentLanguageDisplayText"]
        tapUntilLabelMatches(englishRow, expectedLabel: "English", on: currentLanguageText)
        XCTAssertEqual(currentLanguageText.label, "English", "言語設定画面上の表示がEnglishに変わること")

        let doneButton = app.buttons["languageSettingsDoneButton"]
        XCTAssertTrue(doneButton.waitForExistence(timeout: 5))
        doneButton.tap()

        // 言語切替後、消費ボタンのラベルが英語表記に変わっていること
        let consumeButton = app.buttons["consumeButton"]
        let labelPredicate = NSPredicate(format: "label == %@", "Consume Willpower (20)")
        expectation(for: labelPredicate, evaluatedWith: consumeButton)
        waitForExpectations(timeout: 5)

        // 後続の他テストに影響しないよう日本語へ戻す
        languageToggleButton.tap()
        let japaneseRow = app.buttons["languageRow_ja"]
        XCTAssertTrue(japaneseRow.waitForExistence(timeout: 5))
        tapUntilLabelMatches(japaneseRow, expectedLabel: "日本語", on: currentLanguageText)
        doneButton.tap()
    }

#if CRASH_REPORT_TESTING
    @MainActor
    func testCrashReportVerificationRequiresConfirmation() throws {
        let app = XCUIApplication()
        app.launch()
        dismissOnboardingIfPresent(app)

        let languageToggleButton = app.buttons["languageToggleButton"]
        XCTAssertTrue(languageToggleButton.waitForExistence(timeout: 5))
        languageToggleButton.tap()

        let crashReportTestButton = app.buttons["crashReportTestButton"]
        XCTAssertTrue(crashReportTestButton.waitForExistence(timeout: 5), "検証用ビルドだけにボタンが表示されること")
        crashReportTestButton.tap()

        let confirmButton = app.buttons["クラッシュさせる"]
        XCTAssertTrue(confirmButton.waitForExistence(timeout: 5), "意図的クラッシュの前に確認を求めること")

        let cancelButton = app.buttons["キャンセル"]
        XCTAssertTrue(cancelButton.exists)
        cancelButton.tap()
        XCTAssertTrue(app.exists, "キャンセル時はアプリが継続すること")
    }
#endif

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
