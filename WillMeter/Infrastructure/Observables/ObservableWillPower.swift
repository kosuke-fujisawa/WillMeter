//
// ObservableWillPower.swift
// WillMeter
//
// Created by WillMeter Project
// Licensed under CC BY-NC 4.0
// https://creativecommons.org/licenses/by-nc/4.0/
//

import Foundation
import SwiftUI

/// WillPowerエンティティをObservableObjectとしてラップ
/// インフラ層の責務：ドメインエンティティとSwiftUIの橋渡し
/// 汎用ObservableWrapperを継承し、WillPower固有の機能を提供
public class ObservableWillPower: ObservableWrapper<WillPower> {
    // MARK: - ドメインエンティティへの読み取り専用アクセス

    public var currentValue: Int {
        wrappedEntity.currentValue
    }

    public var maxValue: Int {
        wrappedEntity.maxValue
    }

    public var percentage: Double {
        wrappedEntity.percentage
    }

    public var status: WillPowerStatus {
        wrappedEntity.status
    }

    // MARK: - ドメインロジックへの委譲

    /// 意志力を消費する
    /// - Parameter amount: 消費量
    /// - Returns: 消費に成功したかどうか
    @discardableResult
    public func consume(amount: Int) -> Bool {
        return wrappedEntity.consume(amount: amount)
    }

    /// 意志力を回復する
    /// - Parameter amount: 回復量
    public func restore(amount: Int) {
        wrappedEntity.restore(amount: amount)
    }

    /// タスクが実行可能かどうかを判定
    /// - Parameter cost: タスクのコスト
    /// - Returns: 実行可能かどうか
    public func canPerformTask(cost: Int) -> Bool {
        return wrappedEntity.canPerformTask(cost: cost)
    }

    /// リセット（最大値まで回復）
    public func reset() {
        restore(amount: maxValue - currentValue)
    }
}
