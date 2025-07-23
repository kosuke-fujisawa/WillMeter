import Foundation

public class WillPower: ObservableObject {
    @Published private(set) var currentValue: Int
    public let maxValue: Int

    public init(currentValue: Int, maxValue: Int) {
        self.currentValue = max(0, min(currentValue, maxValue))
        self.maxValue = maxValue
    }

    public var percentage: Double {
        guard maxValue > 0 else { return 0.0 }
        return Double(currentValue) / Double(maxValue)
    }

    public var status: WillPowerStatus {
        let percentageValue = percentage
        switch percentageValue {
        case 0.7...1.0:
            return .high
        case 0.3..<0.7:
            return .medium
        case 0.1..<0.3:
            return .low
        default:
            return .critical
        }
    }

    @discardableResult
    public func consume(amount: Int) -> Bool {
        guard amount >= 0, currentValue >= amount else {
            return false
        }

        currentValue -= amount
        return true
    }

    public func restore(amount: Int) {
        guard amount >= 0 else { return }
        currentValue = min(currentValue + amount, maxValue)
    }

    public func canPerformTask(cost: Int) -> Bool {
        return currentValue >= cost && cost >= 0
    }
}

public enum WillPowerStatus: String, CaseIterable {
    case high = "high"
    case medium = "medium"
    case low = "low"
    case critical = "critical"

    public var displayName: String {
        switch self {
        case .high: return "高"
        case .medium: return "中"
        case .low: return "低"
        case .critical: return "危険"
        }
    }

    public var color: String {
        switch self {
        case .high: return "green"
        case .medium: return "yellow"
        case .low: return "orange"
        case .critical: return "red"
        }
    }
}
