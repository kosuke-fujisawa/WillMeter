//
// Task.swift
// WillMeter
//
// Created by WillMeter Project
// Licensed under CC BY-NC 4.0
// https://creativecommons.org/licenses/by-nc/4.0/
//

import Foundation

public class Task: Identifiable, Observable {
    public typealias ObserverType = Task

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

    // 共通Observer実装を委譲
    private let observerMixin = ObserverMixin<Task>()

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

    // MARK: - Observable Protocol Implementation

    /// ドメインイベント観察者の追加
    public func addObserver(_ observer: @escaping (Task) -> Void) {
        observerMixin.addObserver(observer)
    }

    /// ドメインイベント通知
    public func notifyObservers() {
        observerMixin.notifyObservers(with: self)
    }

    public func start() {
        guard status == .pending || status == .paused else {
            return
        }
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
        guard status == .inProgress else {
            return
        }
        status = .paused
        notifyObservers() // ドメインイベント通知
    }

    public func resume() {
        guard status == .paused else {
            return
        }
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

    public var localizationKey: String {
        switch self {
        case .pending: return LocalizationKeys.Task.Status.pending
        case .inProgress: return LocalizationKeys.Task.Status.inProgress
        case .completed: return LocalizationKeys.Task.Status.completed
        case .cancelled: return LocalizationKeys.Task.Status.cancelled
        case .paused: return LocalizationKeys.Task.Status.paused
        }
    }
}

public enum TaskPriority: Int, CaseIterable {
    case low = 1
    case medium = 2
    case high = 3

    public var localizationKey: String {
        switch self {
        case .low: return LocalizationKeys.Task.Priority.low
        case .medium: return LocalizationKeys.Task.Priority.medium
        case .high: return LocalizationKeys.Task.Priority.high
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

    public var localizationKey: String {
        switch self {
        case .work: return LocalizationKeys.Task.Category.work
        case .personal: return LocalizationKeys.Task.Category.personal
        case .health: return LocalizationKeys.Task.Category.health
        case .learning: return LocalizationKeys.Task.Category.learning
        case .development: return LocalizationKeys.Task.Category.development
        case .urgent: return LocalizationKeys.Task.Category.urgent
        case .maintenance: return LocalizationKeys.Task.Category.maintenance
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
