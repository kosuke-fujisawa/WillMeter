//
// ObservableTask.swift
// WillMeter
//
// Created by WillMeter Project
// Licensed under CC BY-NC 4.0
// https://creativecommons.org/licenses/by-nc/4.0/
//

import Foundation
import SwiftUI

/// TaskエンティティをObservableObjectとしてラップ
/// インフラ層の責務：ドメインエンティティとSwiftUIの橋渡し
public class ObservableTask: ObservableObject {
    @Published private var task: Task

    public init(_ task: Task) {
        self.task = task

        // ドメインエンティティの変更を監視してUI更新
        task.addObserver { [weak self] _ in
            DispatchQueue.main.async {
                self?.objectWillChange.send()
            }
        }
    }

    // MARK: - ドメインエンティティへの読み取り専用アクセス

    public var id: UUID {
        task.id
    }

    public var title: String {
        task.title
    }

    public var description: String? {
        task.description
    }

    public var willPowerCost: Int {
        task.willPowerCost
    }

    public var priority: TaskPriority {
        task.priority
    }

    public var category: TaskCategory {
        task.category
    }

    public var status: TaskStatus {
        task.currentStatus
    }

    public var isCompleted: Bool {
        task.isCompleted
    }

    public var priorityScore: Int {
        task.priorityScore
    }

    // MARK: - ドメインロジックへの委譲

    /// タスクを開始する
    public func start() {
        task.start()
    }

    /// タスクを完了する
    public func markAsCompleted() {
        task.markAsCompleted()
    }

    /// タスクをキャンセルする
    public func cancel() {
        task.cancel()
    }

    /// タスクを一時停止する
    public func pause() {
        task.pause()
    }

    /// タスクを再開する
    public func resume() {
        task.resume()
    }

    /// 指定した意志力でタスクが実行可能かどうかを判定
    /// - Parameter willPower: 意志力エンティティ
    /// - Returns: 実行可能かどうか
    public func canBePerformed(with willPower: WillPower) -> Bool {
        return task.canBePerformed(with: willPower)
    }
}
