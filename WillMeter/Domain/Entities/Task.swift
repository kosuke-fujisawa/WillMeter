//
//  Task.swift
//  WillMeter
//
//  Created by WillMeter Project
//  Licensed under CC BY-NC 4.0
//  https://creativecommons.org/licenses/by-nc/4.0/
//

import Foundation

public class Task: Identifiable {
    public let id: UUID
    public var title: String
    public var description: String?
    public var willPowerCost: Int
    public var priority: TaskPriority
    public var category: TaskCategory
    private(set) var status: TaskStatus

    // statusへの公開アクセサ
    public var currentStatus: TaskStatus {
        return status
    }
    public var estimatedDuration: TimeInterval?

    private(set) var createdAt: Date
    private(set) var startedAt: Date?
    private(set) var completedAt: Date?

    // ドメインイベント通知のための観察者パターン
    private var observers: [(Task) -> Void] = []

    public init(
        id: UUID = UUID(),
        title: String,
        description: String? = nil,
        willPowerCost: Int,
        priority: TaskPriority,
        category: TaskCategory,
        estimatedDuration: TimeInterval? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.willPowerCost = max(0, willPowerCost)
        self.priority = priority
        self.category = category
        self.status = .pending
        self.estimatedDuration = estimatedDuration
        self.createdAt = Date()
    }

    public var isCompleted: Bool {
        return status == .completed
    }

    public var priorityScore: Int {
        return priority.rawValue
    }

    // ドメインイベント観察者の追加
    public func addObserver(_ observer: @escaping (Task) -> Void) {
        observers.append(observer)
    }

    // ドメインイベント通知
    private func notifyObservers() {
        observers.forEach { $0(self) }
    }

    public func start() {
        guard status == .pending || status == .paused else { return }
        status = .inProgress
        if startedAt == nil {
            startedAt = Date()
        }
        notifyObservers() // ドメインイベント通知
    }

    public func markAsCompleted() {
        status = .completed
        completedAt = Date()
        notifyObservers() // ドメインイベント通知
    }

    public func cancel() {
        status = .cancelled
        notifyObservers() // ドメインイベント通知
    }

    public func pause() {
        guard status == .inProgress else { return }
        status = .paused
        notifyObservers() // ドメインイベント通知
    }

    public func resume() {
        guard status == .paused else { return }
        status = .inProgress
        notifyObservers() // ドメインイベント通知
    }

    public func setEstimatedDuration(_ duration: TimeInterval) {
        estimatedDuration = duration
    }

    public func canBePerformed(with willPower: WillPower) -> Bool {
        return willPower.canPerformTask(cost: willPowerCost)
    }

    public func updateWillPowerCost(_ newCost: Int) {
        willPowerCost = max(0, newCost)
    }
}

public enum TaskStatus: String, CaseIterable {
    case pending
    case inProgress
    case completed
    case cancelled
    case paused

    public var displayName: String {
        switch self {
        case .pending: return "未開始"
        case .inProgress: return "実行中"
        case .completed: return "完了"
        case .cancelled: return "キャンセル"
        case .paused: return "一時停止"
        }
    }
}

public enum TaskPriority: Int, CaseIterable {
    case low = 1
    case medium = 2
    case high = 3

    public var displayName: String {
        switch self {
        case .low: return "低"
        case .medium: return "中"
        case .high: return "高"
        }
    }
}

public enum TaskCategory: String, CaseIterable {
    case work
    case personal
    case health
    case learning
    case development
    case urgent
    case maintenance

    public var displayName: String {
        switch self {
        case .work: return "仕事"
        case .personal: return "個人"
        case .health: return "健康"
        case .learning: return "学習"
        case .development: return "開発"
        case .urgent: return "緊急"
        case .maintenance: return "メンテナンス"
        }
    }

    public var iconName: String {
        switch self {
        case .work: return "briefcase"
        case .personal: return "person"
        case .health: return "heart"
        case .learning: return "book"
        case .development: return "hammer"
        case .urgent: return "exclamationmark.triangle"
        case .maintenance: return "wrench"
        }
    }
}
