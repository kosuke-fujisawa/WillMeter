@testable import WillMeter
import XCTest

final class TaskTests: XCTestCase {
    func testTaskInitialization() throws {
        // Given
        let id = UUID()
        let title = "プログラミング学習"
        let description = "SwiftUIアプリの開発"
        let willPowerCost = 30
        let priority = TaskPriority.high
        let category = TaskCategory.development

        // When
        let task = Task(
            id: id,
            title: title,
            description: description,
            willPowerCost: willPowerCost,
            priority: priority,
            category: category
        )

        // Then
        XCTAssertEqual(task.id, id)
        XCTAssertEqual(task.title, title)
        XCTAssertEqual(task.description, description)
        XCTAssertEqual(task.willPowerCost, willPowerCost)
        XCTAssertEqual(task.priority, priority)
        XCTAssertEqual(task.category, category)
        XCTAssertEqual(task.status, .pending)
        XCTAssertFalse(task.isCompleted)
    }

    func testTaskCompletion() throws {
        // Given
        let task = createSampleTask()

        // When
        task.markAsCompleted()

        // Then
        XCTAssertEqual(task.status, .completed)
        XCTAssertTrue(task.isCompleted)
        XCTAssertNotNil(task.completedAt)
    }

    func testTaskStart() throws {
        // Given
        let task = createSampleTask()

        // When
        task.start()

        // Then
        XCTAssertEqual(task.status, .inProgress)
        XCTAssertFalse(task.isCompleted)
        XCTAssertNotNil(task.startedAt)
    }

    func testTaskCancel() throws {
        // Given
        let task = createSampleTask()
        task.start()

        // When
        task.cancel()

        // Then
        XCTAssertEqual(task.status, .cancelled)
        XCTAssertFalse(task.isCompleted)
    }

    func testTaskPause() throws {
        // Given
        let task = createSampleTask()
        task.start()

        // When
        task.pause()

        // Then
        XCTAssertEqual(task.status, .paused)
        XCTAssertFalse(task.isCompleted)
    }

    func testTaskResume() throws {
        // Given
        let task = createSampleTask()
        task.start()
        task.pause()

        // When
        task.resume()

        // Then
        XCTAssertEqual(task.status, .inProgress)
        XCTAssertFalse(task.isCompleted)
    }

    func testTaskEstimatedDuration() throws {
        // Given
        let task = createSampleTask()
        let expectedDuration: TimeInterval = 3_600 // 1 hour

        // When
        task.setEstimatedDuration(expectedDuration)

        // Then
        XCTAssertEqual(task.estimatedDuration, expectedDuration)
    }

    func testTaskPriorityScore() throws {
        // Given & When & Then
        let highPriorityTask = Task(
            title: "緊急タスク",
            willPowerCost: 30,
            priority: .high,
            category: .urgent
        )
        XCTAssertEqual(highPriorityTask.priorityScore, 3)

        let mediumPriorityTask = Task(
            title: "通常タスク",
            willPowerCost: 20,
            priority: .medium,
            category: .work
        )
        XCTAssertEqual(mediumPriorityTask.priorityScore, 2)

        let lowPriorityTask = Task(
            title: "後回しタスク",
            willPowerCost: 10,
            priority: .low,
            category: .personal
        )
        XCTAssertEqual(lowPriorityTask.priorityScore, 1)
    }

    func testTaskCanBePerformed() throws {
        // Given
        let task = createSampleTask()
        let willPower = WillPower(currentValue: 50, maxValue: 100)

        // When & Then
        XCTAssertTrue(task.canBePerformed(with: willPower))

        // When willPower is insufficient
        let insufficientWillPower = WillPower(currentValue: 20, maxValue: 100)
        XCTAssertFalse(task.canBePerformed(with: insufficientWillPower))
    }

    // MARK: - Helper Methods

    private func createSampleTask() -> Task {
        return Task(
            title: "サンプルタスク",
            description: "テスト用のサンプルタスクです",
            willPowerCost: 30,
            priority: .medium,
            category: .development
        )
    }
}
