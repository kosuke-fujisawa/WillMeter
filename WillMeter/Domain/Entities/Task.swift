import Foundation

public class Task: ObservableObject, Identifiable {
    public let id: UUID
    @Published public var title: String
    @Published public var description: String?
    @Published public var willPowerCost: Int
    @Published public var priority: TaskPriority
    @Published public var category: TaskCategory
    @Published public private(set) var status: TaskStatus
    @Published public var estimatedDuration: TimeInterval?
    
    @Published public private(set) var createdAt: Date
    @Published public private(set) var startedAt: Date?
    @Published public private(set) var completedAt: Date?
    
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
    
    public func start() {
        guard status == .pending || status == .paused else { return }
        status = .inProgress
        if startedAt == nil {
            startedAt = Date()
        }
    }
    
    public func markAsCompleted() {
        status = .completed
        completedAt = Date()
    }
    
    public func cancel() {
        status = .cancelled
    }
    
    public func pause() {
        guard status == .inProgress else { return }
        status = .paused
    }
    
    public func resume() {
        guard status == .paused else { return }
        status = .inProgress
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
    case pending = "pending"
    case inProgress = "inProgress" 
    case completed = "completed"
    case cancelled = "cancelled"
    case paused = "paused"
    
    public var displayName: String {
        switch self {
        case .pending: return "未開始"
        case .inProgress: return "実行中"
        case .completed: return "完了"
        case .cancelled: return "キャンセル"
        case .paused: return "一時停止"
        }
    }
    
    public var color: String {
        switch self {
        case .pending: return "blue"
        case .inProgress: return "orange"
        case .completed: return "green"
        case .cancelled: return "red"
        case .paused: return "yellow"
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
    
    public var color: String {
        switch self {
        case .low: return "green"
        case .medium: return "yellow"
        case .high: return "red"
        }
    }
}

public enum TaskCategory: String, CaseIterable {
    case work = "work"
    case personal = "personal"
    case health = "health"
    case learning = "learning"
    case development = "development"
    case urgent = "urgent"
    case maintenance = "maintenance"
    
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