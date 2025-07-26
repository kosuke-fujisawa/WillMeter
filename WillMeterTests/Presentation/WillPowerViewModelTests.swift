//
// WillPowerViewModelTests.swift
// WillMeterTests
//
// Created by WillMeter Project
// Licensed under CC BY-NC 4.0
// https://creativecommons.org/licenses/by-nc/4.0/
//

@testable import WillMeter
import XCTest

@MainActor
final class WillPowerViewModelTests: XCTestCase {
    var viewModel: WillPowerViewModel!
    var mockRepository: InMemoryWillPowerRepository!
    var useCase: WillPowerUseCase!

    override func setUp() {
        super.setUp()
        mockRepository = InMemoryWillPowerRepository()
        useCase = WillPowerUseCase(repository: mockRepository)
        viewModel = WillPowerViewModel(willPowerUseCase: useCase)
    }

    override func tearDown() {
        viewModel = nil
        useCase = nil
        mockRepository = nil
        super.tearDown()
    }

    // ヘルパーメソッド：ViewModelの初期化完了を確実に待機
    private func waitForViewModelInitialization() async {
        // ViewModelの初期化状態を確認
        // 初期値が設定されるまで待機（最大1秒）
        var attempts = 0
        let maxAttempts = 10

        while viewModel.currentValue == 0 && attempts < maxAttempts {
            try? await _Concurrency.Task.sleep(nanoseconds: 100_000_000) // 0.1 second
            attempts += 1
        }
    }

    func testInitialState() async throws {
        // Given - Ensure ViewModel is properly initialized
        await waitForViewModelInitialization()

        // Then
        XCTAssertEqual(viewModel.currentValue, 100)
        XCTAssertEqual(viewModel.maxValue, 100)
        XCTAssertEqual(viewModel.percentage, 1.0, accuracy: 0.01)
        XCTAssertEqual(viewModel.status, .high)
    }

    func testConsumeWillPower() async throws {
        // Given - Ensure ViewModel is properly initialized
        await waitForViewModelInitialization()
        let consumeAmount = 30

        // When
        let result = viewModel.consumeWillPower(amount: consumeAmount)

        // Then
        XCTAssertTrue(result)
        XCTAssertEqual(viewModel.currentValue, 70)
        XCTAssertEqual(viewModel.percentage, 0.7, accuracy: 0.01)
        XCTAssertEqual(viewModel.status, .high)
    }

    func testConsumeWillPowerFails() async throws {
        // Given - Ensure ViewModel is properly initialized
        await waitForViewModelInitialization()
        viewModel.consumeWillPower(amount: 80) // Reduce to 20
        let consumeAmount = 30

        // When
        let result = viewModel.consumeWillPower(amount: consumeAmount)

        // Then
        XCTAssertFalse(result)
        XCTAssertEqual(viewModel.currentValue, 20) // Should remain unchanged
    }

    func testRestoreWillPower() async throws {
        // Given - Ensure ViewModel is properly initialized
        await waitForViewModelInitialization()
        viewModel.consumeWillPower(amount: 50) // Reduce to 50
        let restoreAmount = 30

        // When
        viewModel.restoreWillPower(amount: restoreAmount)

        // Then
        XCTAssertEqual(viewModel.currentValue, 80)
        XCTAssertEqual(viewModel.percentage, 0.8, accuracy: 0.01)
        XCTAssertEqual(viewModel.status, .high)
    }

    func testCanPerformTask() async throws {
        // Given - Ensure ViewModel is properly initialized
        await waitForViewModelInitialization()
        let task = Task(title: "Test Task",
                        willPowerCost: 30,
                        priority: .medium,
                        category: .work)

        // When & Then
        XCTAssertTrue(viewModel.canPerformTask(task))

        // Given - reduce will power
        viewModel.consumeWillPower(amount: 80) // Reduce to 20

        // When & Then
        XCTAssertFalse(viewModel.canPerformTask(task))
    }

    func testPerformTask() async throws {
        // Given - Ensure ViewModel is properly initialized
        await waitForViewModelInitialization()
        let task = Task(title: "Test Task",
                        willPowerCost: 30,
                        priority: .medium,
                        category: .work)

        // When
        let result = viewModel.performTask(task)

        // Then
        XCTAssertTrue(result)
        XCTAssertEqual(viewModel.currentValue, 70)
        XCTAssertEqual(task.currentStatus, .completed)
    }

    func testPerformTaskFails() async throws {
        // Given - Ensure ViewModel is properly initialized
        await waitForViewModelInitialization()
        let task = Task(title: "Test Task",
                        willPowerCost: 30,
                        priority: .medium,
                        category: .work)
        viewModel.consumeWillPower(amount: 80) // Reduce to 20

        // When
        let result = viewModel.performTask(task)

        // Then
        XCTAssertFalse(result)
        XCTAssertEqual(viewModel.currentValue, 20) // Should remain unchanged
        XCTAssertEqual(task.currentStatus, .pending) // Task should not be completed
    }

    func testStatusUpdatesCorrectly() async throws {
        // Given - Ensure ViewModel is properly initialized
        await waitForViewModelInitialization()

        // Initially high (100)
        XCTAssertEqual(viewModel.status, .high)

        // Reduce to medium range
        viewModel.consumeWillPower(amount: 50) // 50 remaining
        XCTAssertEqual(viewModel.status, .medium)

        // Reduce to low range
        viewModel.consumeWillPower(amount: 30) // 20 remaining
        XCTAssertEqual(viewModel.status, .low)

        // Reduce to critical range
        viewModel.consumeWillPower(amount: 15) // 5 remaining
        XCTAssertEqual(viewModel.status, .critical)
    }

    func testResetWillPower() async throws {
        // Given - Ensure ViewModel is properly initialized
        await waitForViewModelInitialization()
        viewModel.consumeWillPower(amount: 50) // Reduce to 50

        // When
        viewModel.resetWillPower()

        // Then
        XCTAssertEqual(viewModel.currentValue, 100)
        XCTAssertEqual(viewModel.percentage, 1.0, accuracy: 0.01)
        XCTAssertEqual(viewModel.status, .high)
    }
}
