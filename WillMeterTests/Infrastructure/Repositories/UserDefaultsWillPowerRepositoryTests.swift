//
// UserDefaultsWillPowerRepositoryTests.swift
// WillMeterTests
//
// Created by WillMeter Project
// Licensed under CC BY-NC 4.0
// https://creativecommons.org/licenses/by-nc/4.0/
//

@testable import WillMeter
import XCTest

final class UserDefaultsWillPowerRepositoryTests: XCTestCase {
    private let currentValueKey = "willPower.currentValue"
    private let maxValueKey = "willPower.maxValue"
    private var userDefaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = "UserDefaultsWillPowerRepositoryTests.\(UUID().uuidString)"
        userDefaults = UserDefaults(suiteName: suiteName)
    }

    override func tearDown() {
        userDefaults.removePersistentDomain(forName: suiteName)
        userDefaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testSaveAndLoadReturnsPersistedValue() async throws {
        // Given
        let repository = UserDefaultsWillPowerRepository(userDefaults: userDefaults)
        let willPower = WillPower(currentValue: 70, maxValue: 100)

        // When
        try await repository.save(willPower)
        let loaded = try await repository.load()

        // Then
        XCTAssertEqual(loaded.currentValue, 70)
        XCTAssertEqual(loaded.maxValue, 100)
    }

    func testLoadWithNoStoredDataReturnsDefault() async throws {
        // Given
        let repository = UserDefaultsWillPowerRepository(userDefaults: userDefaults)

        // When
        let loaded = try await repository.load()

        // Then
        assertDefaultWillPower(loaded)
    }

    func testSaveOverwritesPreviousValue() async throws {
        // Given
        let repository = UserDefaultsWillPowerRepository(userDefaults: userDefaults)
        try await repository.save(WillPower(currentValue: 40, maxValue: 100))

        // When
        try await repository.save(WillPower(currentValue: 90, maxValue: 100))
        let loaded = try await repository.load()

        // Then
        XCTAssertEqual(loaded.currentValue, 90)
    }

    func testDataPersistsAcrossRepositoryInstances() async throws {
        // Given: アプリ再起動を模して、保存と読み込みで別インスタンスを使う
        let writerRepository = UserDefaultsWillPowerRepository(userDefaults: userDefaults)
        try await writerRepository.save(WillPower(currentValue: 55, maxValue: 100))

        // When
        let readerRepository = UserDefaultsWillPowerRepository(userDefaults: userDefaults)
        let loaded = try await readerRepository.load()

        // Then
        XCTAssertEqual(loaded.currentValue, 55)
        XCTAssertEqual(loaded.maxValue, 100)
    }

    func testLoadWithOnlyMaxValueReturnsDefault() async throws {
        // Given: 保存途中の中断などで最大値だけが残った破損状態
        userDefaults.set(100, forKey: maxValueKey)
        let repository = UserDefaultsWillPowerRepository(userDefaults: userDefaults)

        // When
        let loaded = try await repository.load()

        // Then: 欠損した現在値を0と誤認せず、安全なデフォルトへ戻す
        assertDefaultWillPower(loaded)
    }

    func testLoadClampsNegativeCurrentValueToZero() async throws {
        // Given: 永続化データの現在値がドメイン下限を下回っている
        userDefaults.set(-1, forKey: currentValueKey)
        userDefaults.set(100, forKey: maxValueKey)
        let repository = UserDefaultsWillPowerRepository(userDefaults: userDefaults)

        // When
        let loaded = try await repository.load()

        // Then: WillPowerの不変条件に従い下限へ補正する
        XCTAssertEqual(loaded.currentValue, 0)
        XCTAssertEqual(loaded.maxValue, 100)
    }

    func testLoadClampsCurrentValueAboveMaximum() async throws {
        // Given: 永続化データの現在値が最大値を超えている
        userDefaults.set(101, forKey: currentValueKey)
        userDefaults.set(100, forKey: maxValueKey)
        let repository = UserDefaultsWillPowerRepository(userDefaults: userDefaults)

        // When
        let loaded = try await repository.load()

        // Then: WillPowerの不変条件に従い上限へ補正する
        XCTAssertEqual(loaded.currentValue, 100)
        XCTAssertEqual(loaded.maxValue, 100)
    }

    func testLoadWithNonIntegerCurrentValueReturnsDefault() async throws {
        // Given: 現在値キーに互換性のない型が保存されている
        userDefaults.set("invalid", forKey: currentValueKey)
        userDefaults.set(100, forKey: maxValueKey)
        let repository = UserDefaultsWillPowerRepository(userDefaults: userDefaults)

        // When
        let loaded = try await repository.load()

        // Then: 変換結果の0を有効値と誤認せず、デフォルトへ回復する
        assertDefaultWillPower(loaded)
    }

    func testLoadWithNonIntegerMaxValueReturnsDefault() async throws {
        // Given: 最大値キーに互換性のない型が保存されている
        userDefaults.set(50, forKey: currentValueKey)
        userDefaults.set("100", forKey: maxValueKey)
        let repository = UserDefaultsWillPowerRepository(userDefaults: userDefaults)

        // When
        let loaded = try await repository.load()

        // Then: 文字列を有効な最大値と解釈せず、デフォルトへ回復する
        assertDefaultWillPower(loaded)
    }

    private func assertDefaultWillPower(
        _ willPower: WillPower,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(willPower.currentValue, WillPower.defaultCurrentValue, file: file, line: line)
        XCTAssertEqual(willPower.maxValue, WillPower.defaultMaxValue, file: file, line: line)
    }
}
