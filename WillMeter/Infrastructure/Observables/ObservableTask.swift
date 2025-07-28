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
/// 汎用ObservableWrapperを継承し、Task固有の機能を提供
public class ObservableTask: ObservableWrapper<Task> {
    // MARK: - ドメインエンティティへの読み取り専用アクセス

    public var id: UUID {
        wrappedEntity.id
    }

    public var title: String {
        wrappedEntity.title
    }

    public var description: String? {
        wrappedEntity.description
    }

    public var willPowerCost: Int {
        wrappedEntity.willPowerCost
    }

    public var priority: TaskPriority {
        wrappedEntity.priority
    }

    public var category: TaskCategory {
        wrappedEntity.category
    }

    public var status: TaskStatus {
        wrappedEntity.currentStatus
    }

    public var isCompleted: Bool {
        wrappedEntity.isCompleted
    }

    public var priorityScore: Int {
        wrappedEntity.priorityScore
    }

    // MARK: - ドメインロジックへの委譲

    /// タスクを開始する
    public func start() {
        wrappedEntity.start()
    }

    /// タスクを完了する
    public func markAsCompleted() {
        wrappedEntity.markAsCompleted()
    }

    /// タスクをキャンセルする
    public func cancel() {
        wrappedEntity.cancel()
    }

    /// タスクを一時停止する
    public func pause() {
        wrappedEntity.pause()
    }

    /// タスクを再開する
    public func resume() {
        wrappedEntity.resume()
    }

    /// 指定した意志力でタスクが実行可能かどうかを判定
    /// - Parameter willPower: 意志力エンティティ
    /// - Returns: 実行可能かどうか
    public func canBePerformed(with willPower: WillPower) -> Bool {
        return wrappedEntity.canBePerformed(with: willPower)
    }
}
