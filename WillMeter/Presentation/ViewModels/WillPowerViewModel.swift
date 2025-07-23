import Combine
import Foundation

@MainActor
public class WillPowerViewModel: ObservableObject {
    @Published private var willPower: WillPower

    public init(initialValue: Int = 100, maxValue: Int = 100) {
        self.willPower = WillPower(currentValue: initialValue, maxValue: maxValue)
    }

    // MARK: - Published Properties

    public var currentValue: Int {
        willPower.currentValue
    }

    public var maxValue: Int {
        willPower.maxValue
    }

    public var percentage: Double {
        willPower.percentage
    }

    public var status: WillPowerStatus {
        willPower.status
    }

    // MARK: - Actions

    @discardableResult
    public func consumeWillPower(amount: Int) -> Bool {
        let result = willPower.consume(amount: amount)
        objectWillChange.send()
        return result
    }

    public func restoreWillPower(amount: Int) {
        willPower.restore(amount: amount)
        objectWillChange.send()
    }

    public func resetWillPower() {
        willPower.restore(amount: willPower.maxValue - willPower.currentValue)
        objectWillChange.send()
    }

    // MARK: - Task Related Methods

    public func canPerformTask(_ task: Task) -> Bool {
        return willPower.canPerformTask(cost: task.willPowerCost)
    }

    @discardableResult
    public func performTask(_ task: Task) -> Bool {
        guard canPerformTask(task) else {
            return false
        }

        let success = willPower.consume(amount: task.willPowerCost)
        if success {
            task.markAsCompleted()
            objectWillChange.send()
        }
        return success
    }

    // MARK: - Computed Properties for UI

    public var displayText: String {
        return "\(currentValue) / \(maxValue)"
    }

    public var statusText: String {
        return "\(status.displayName) (\(Int(percentage * 100))%)"
    }

    public var statusColor: String {
        switch status {
        case .high: return "green"
        case .medium: return "yellow"
        case .low: return "orange"
        case .critical: return "red"
        }
    }

    public var isLowWillPower: Bool {
        return status == .low || status == .critical
    }

    public var isCriticalWillPower: Bool {
        return status == .critical
    }

    // MARK: - Recommendations

    public var recommendedAction: String {
        switch status {
        case .high:
            return "新しいタスクに挑戦する絶好のタイミングです！"
        case .medium:
            return "適度なタスクを選んで取り組みましょう。"
        case .low:
            return "簡単なタスクに集中するか、休憩を取ることをお勧めします。"
        case .critical:
            return "休憩を取って意思力を回復させましょう。"
        }
    }

    public func getSuggestedTasks(from tasks: [Task]) -> [Task] {
        return tasks.filter { task in
            canPerformTask(task)
        }.sorted { task1, task2 in
            // Priority based sorting
            if task1.priority.rawValue != task2.priority.rawValue {
                return task1.priority.rawValue > task2.priority.rawValue
            }
            // If same priority, sort by will power cost (ascending)
            return task1.willPowerCost < task2.willPowerCost
        }
    }
}
