//
// WillPowerViewModel.swift
// WillMeter
//
// プレゼンテーション層：UI専用のロジックとデータ変換

import Combine
import Foundation
import SwiftUI

@MainActor
public class WillPowerViewModel: ObservableObject {
    private let observableWillPower: ObservableWillPower

    public init(willPower: WillPower? = nil) {
        let domainEntity = willPower ?? WillPower(currentValue: 100, maxValue: 100)
        self.observableWillPower = ObservableWillPower(domainEntity)
        
        // インフラ層のObservableWillPowerの変更を監視してUI更新
        observableWillPower.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()

    // MARK: - ドメインエンティティへの読み取り専用アクセス

    public var currentValue: Int {
        observableWillPower.currentValue
    }

    public var maxValue: Int {
        observableWillPower.maxValue
    }

    public var percentage: Double {
        observableWillPower.percentage
    }

    public var status: WillPowerStatus {
        observableWillPower.status
    }

    // MARK: - ユーザーアクション（ドメインロジックへの委譲）

    @discardableResult
    public func consumeWillPower(amount: Int) -> Bool {
        return observableWillPower.consume(amount: amount)
    }

    public func restoreWillPower(amount: Int) {
        observableWillPower.restore(amount: amount)
    }

    public func resetWillPower() {
        observableWillPower.reset()
    }

    // MARK: - Task Related Methods

    public func canPerformTask(_ task: Task) -> Bool {
        return observableWillPower.canPerformTask(cost: task.willPowerCost)
    }

    @discardableResult
    public func performTask(_ task: Task) -> Bool {
        guard canPerformTask(task) else {
            return false
        }

        let success = observableWillPower.consume(amount: task.willPowerCost)
        if success {
            task.markAsCompleted()
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
