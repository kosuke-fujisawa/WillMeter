//
// InMemoryWillPowerRepository.swift
// WillMeter
//
// Created by WillMeter Project
// Licensed under CC BY-NC 4.0
// https://creativecommons.org/licenses/by-nc/4.0/
//

import Foundation

/// WillPowerRepositoryのインメモリ実装
/// インフラ層の責務：データの永続化と取得（開発・テスト用）
public class InMemoryWillPowerRepository: WillPowerRepository {
    private struct StoredWillPower {
        let currentValue: Int
        let maxValue: Int
    }

    private var storedWillPower: StoredWillPower?

    public init() {}

    public func save(_ willPower: WillPower) async throws {
        storedWillPower = StoredWillPower(
            currentValue: willPower.currentValue,
            maxValue: willPower.maxValue
        )
    }

    public func load() async throws -> WillPower {
        guard let stored = storedWillPower else {
            return WillPower.makeDefault()
        }
        return WillPower(currentValue: stored.currentValue, maxValue: stored.maxValue)
    }
}
