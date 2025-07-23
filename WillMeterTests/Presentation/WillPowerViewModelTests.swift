@testable import WillMeter
import XCTest

@MainActor
final class WillPowerViewModelTests: XCTestCase {
    var viewModel: WillPowerViewModel!

    override func setUp() {
        super.setUp()
        viewModel = WillPowerViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func testInitialState() throws {
        // Then
        XCTAssertEqual(viewModel.currentValue, 100)
        XCTAssertEqual(viewModel.maxValue, 100)
        XCTAssertEqual(viewModel.percentage, 1.0, accuracy: 0.01)
        XCTAssertEqual(viewModel.status, .high)
    }

    func testConsumeWillPower() throws {
        // Given
        let consumeAmount = 30

        // When
        let result = viewModel.consumeWillPower(amount: consumeAmount)

        // Then
        XCTAssertTrue(result)
        XCTAssertEqual(viewModel.currentValue, 70)
        XCTAssertEqual(viewModel.percentage, 0.7, accuracy: 0.01)
        XCTAssertEqual(viewModel.status, .high)
    }

    func testConsumeWillPowerFails() throws {
        // Given
        viewModel.consumeWillPower(amount: 80) // Reduce to 20
        let consumeAmount = 30

        // When
        let result = viewModel.consumeWillPower(amount: consumeAmount)

        // Then
        XCTAssertFalse(result)
        XCTAssertEqual(viewModel.currentValue, 20) // Should remain unchanged
    }

    func testRestoreWillPower() throws {
        // Given
        viewModel.consumeWillPower(amount: 50) // Reduce to 50
        let restoreAmount = 30

        // When
        viewModel.restoreWillPower(amount: restoreAmount)

        // Then
        XCTAssertEqual(viewModel.currentValue, 80)
        XCTAssertEqual(viewModel.percentage, 0.8, accuracy: 0.01)
        XCTAssertEqual(viewModel.status, .high)
    }

    func testCanPerformTask() throws {
        // Given
        let task = Task(title: "Test Task", willPowerCost: 30, priority: .medium, category: .work)

        // When & Then
        XCTAssertTrue(viewModel.canPerformTask(task))

        // Given - reduce will power
        viewModel.consumeWillPower(amount: 80) // Reduce to 20

        // When & Then
        XCTAssertFalse(viewModel.canPerformTask(task))
    }

    func testPerformTask() throws {
        // Given
        let task = Task(title: "Test Task", willPowerCost: 30, priority: .medium, category: .work)

        // When
        let result = viewModel.performTask(task)

        // Then
        XCTAssertTrue(result)
        XCTAssertEqual(viewModel.currentValue, 70)
        XCTAssertEqual(task.status, .completed)
    }

    func testPerformTaskFails() throws {
        // Given
        let task = Task(title: "Test Task", willPowerCost: 30, priority: .medium, category: .work)
        viewModel.consumeWillPower(amount: 80) // Reduce to 20

        // When
        let result = viewModel.performTask(task)

        // Then
        XCTAssertFalse(result)
        XCTAssertEqual(viewModel.currentValue, 20) // Should remain unchanged
        XCTAssertEqual(task.status, .pending) // Task should not be completed
    }

    func testStatusUpdatesCorrectly() throws {
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

    func testResetWillPower() throws {
        // Given
        viewModel.consumeWillPower(amount: 50) // Reduce to 50

        // When
        viewModel.resetWillPower()

        // Then
        XCTAssertEqual(viewModel.currentValue, 100)
        XCTAssertEqual(viewModel.percentage, 1.0, accuracy: 0.01)
        XCTAssertEqual(viewModel.status, .high)
    }
}
