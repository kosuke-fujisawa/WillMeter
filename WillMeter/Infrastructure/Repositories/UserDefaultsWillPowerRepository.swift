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
        // save()は現在値と最大値を必ず対で保存するため、片方の欠損や型不一致は
        // 既存の保存形式ではなく破損データとして扱い、安全なデフォルトへ戻す
        guard let maxValue = userDefaults.object(forKey: maxValueKey) as? Int,
              let currentValue = userDefaults.object(forKey: currentValueKey) as? Int,
              maxValue > 0 else {
            return WillPower.makeDefault()
        }

        return WillPower(currentValue: currentValue, maxValue: maxValue)
    }
}
