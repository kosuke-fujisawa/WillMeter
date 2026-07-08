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
        XCTAssertEqual(loaded.currentValue, RepositoryUtils.DefaultWillPower.currentValue)
        XCTAssertEqual(loaded.maxValue, RepositoryUtils.DefaultWillPower.maxValue)
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
}
