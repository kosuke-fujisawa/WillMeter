//
// ObservableWillPower.swift
// WillMeter
//
// インフラ層：WillPowerエンティティのSwiftUI統合

import Foundation
import SwiftUI

/// WillPowerエンティティをObservableObjectとしてラップ
/// インフラ層の責務：ドメインエンティティとSwiftUIの橋渡し
@MainActor
public final class ObservableWillPower: ObservableObject {
    @Published private var willPower: WillPower

    public init(_ willPower: WillPower) {
        self.willPower = willPower

        // ドメインエンティティの変更を監視してUI更新
        willPower.addObserver { [weak self] _ in
            self?.objectWillChange.send()
        }
    }

    // MARK: - ドメインエンティティへの読み取り専用アクセス

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

    // MARK: - ドメインロジックへの委譲

    /// 意志力を消費する
    /// - Parameter amount: 消費量
    /// - Returns: 消費に成功したかどうか
    @discardableResult
    public func consume(amount: Int) -> Bool {
        let result = willPower.consume(amount: amount)
        // ドメインエンティティが既に通知するため、ここでは追加通知不要
        return result
    }

    /// 意志力を回復する
    /// - Parameter amount: 回復量
    public func restore(amount: Int) {
        willPower.restore(amount: amount)
        // ドメインエンティティが既に通知するため、ここでは追加通知不要
    }

    /// タスクが実行可能かどうかを判定
    /// - Parameter cost: タスクのコスト
    /// - Returns: 実行可能かどうか
    public func canPerformTask(cost: Int) -> Bool {
        return willPower.canPerformTask(cost: cost)
    }

    /// リセット（最大値まで回復）
    public func reset() {
        restore(amount: maxValue - currentValue)
    }
}
