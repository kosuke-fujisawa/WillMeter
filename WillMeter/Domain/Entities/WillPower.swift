//
//  WillPower.swift
//  WillMeter
//
//  Created by WillMeter Project
//  Licensed under CC BY-NC 4.0
//  https://creativecommons.org/licenses/by-nc/4.0/
//

import Foundation

public class WillPower {
    private(set) var currentValue: Int
    public let maxValue: Int

    // ドメインイベント通知のための観察者パターン
    private var observers: [(WillPower) -> Void] = []

    public init(currentValue: Int, maxValue: Int) {
        self.currentValue = max(0, min(currentValue, maxValue))
        self.maxValue = maxValue
    }

    public var percentage: Double {
        guard maxValue > 0 else {
            return 0.0
        }
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

    // ドメインイベント観察者の追加
    public func addObserver(_ observer: @escaping (WillPower) -> Void) {
        observers.append(observer)
    }

    // ドメインイベント通知
    private func notifyObservers() {
        observers.forEach { $0(self) }
    }

    @discardableResult
    public func consume(amount: Int) -> Bool {
        guard amount >= 0, currentValue >= amount else {
            return false
        }

        currentValue -= amount
        notifyObservers() // ドメインイベント通知
        return true
    }

    public func restore(amount: Int) {
        guard amount >= 0 else {
            return
        }
        currentValue = min(currentValue + amount, maxValue)
        notifyObservers() // ドメインイベント通知
    }

    public func canPerformTask(cost: Int) -> Bool {
        return currentValue >= cost && cost >= 0
    }
}

public enum WillPowerStatus: String, CaseIterable {
    case high
    case medium
    case low
    case critical

    public var localizationKey: String {
        switch self {
        case .high: return LocalizationKeys.WillPower.Status.high
        case .medium: return LocalizationKeys.WillPower.Status.medium
        case .low: return LocalizationKeys.WillPower.Status.low
        case .critical: return LocalizationKeys.WillPower.Status.critical
        }
    }
}
