//
// UserDefaultsWillPowerRepository.swift
// WillMeter
//
// Created by WillMeter Project
// Licensed under CC BY-NC 4.0
// https://creativecommons.org/licenses/by-nc/4.0/
//

import Foundation

/// WillPowerRepositoryのUserDefaults実装
/// インフラ層の責務：データの永続化と取得
public class UserDefaultsWillPowerRepository: WillPowerRepository {
    private let userDefaults: UserDefaults
    private let currentValueKey = "willPower.currentValue"
    private let maxValueKey = "willPower.maxValue"

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    public func save(_ willPower: WillPower) async throws {
        userDefaults.set(willPower.currentValue, forKey: currentValueKey)
        userDefaults.set(willPower.maxValue, forKey: maxValueKey)
    }

    public func load() async throws -> WillPower {
        let maxValue = userDefaults.integer(forKey: maxValueKey)

        // 初回起動時（未保存）は共通デフォルトを使用
        guard maxValue > 0 else {
            return WillPower.makeDefault()
        }

        let currentValue = userDefaults.integer(forKey: currentValueKey)
        return WillPower(currentValue: currentValue, maxValue: maxValue)
    }
}
