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

    func testInitialState() async throws {
        // Given - Wait for async loading to complete
        try await _Concurrency.Task.sleep(nanoseconds: 100_000_000) // 0.1 second

        // Then
        XCTAssertEqual(viewModel.currentValue, 100)
        XCTAssertEqual(viewModel.maxValue, 100)
        XCTAssertEqual(viewModel.percentage, 1.0, accuracy: 0.01)
        XCTAssertEqual(viewModel.status, .high)
    }

    func testConsumeWillPower() async throws {
        // Given - Wait for async loading to complete
        try await _Concurrency.Task.sleep(nanoseconds: 100_000_000) // 0.1 second
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
        // Given - Wait for async loading to complete
        try await _Concurrency.Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        viewModel.consumeWillPower(amount: 80) // Reduce to 20
        let consumeAmount = 30

        // When
        let result = viewModel.consumeWillPower(amount: consumeAmount)

        // Then
        XCTAssertFalse(result)
        XCTAssertEqual(viewModel.currentValue, 20) // Should remain unchanged
    }

    func testRestoreWillPower() async throws {
        // Given - Wait for async loading to complete
        try await _Concurrency.Task.sleep(nanoseconds: 100_000_000) // 0.1 second
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
        // Given - Wait for async loading to complete
        try await _Concurrency.Task.sleep(nanoseconds: 100_000_000) // 0.1 second
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
        // Given - Wait for async loading to complete
        try await _Concurrency.Task.sleep(nanoseconds: 100_000_000) // 0.1 second
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
        // Given - Wait for async loading to complete
        try await _Concurrency.Task.sleep(nanoseconds: 100_000_000) // 0.1 second
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
        // Given - Wait for async loading to complete
        try await _Concurrency.Task.sleep(nanoseconds: 100_000_000) // 0.1 second

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
        // Given - Wait for async loading to complete
        try await _Concurrency.Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        viewModel.consumeWillPower(amount: 50) // Reduce to 50

        // When
        viewModel.resetWillPower()

        // Then
        XCTAssertEqual(viewModel.currentValue, 100)
        XCTAssertEqual(viewModel.percentage, 1.0, accuracy: 0.01)
        XCTAssertEqual(viewModel.status, .high)
    }
}
