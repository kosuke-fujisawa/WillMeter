//
// InMemoryWillPowerRepository.swift
// WillMeter
//
// インフラ層：WillPowerRepositoryのインメモリ実装

import Foundation

/// WillPowerRepositoryのインメモリ実装
/// インフラ層の責務：データの永続化と取得（開発・テスト用）
public class InMemoryWillPowerRepository: WillPowerRepository {
    private var storedWillPower: WillPower?
    
    public init() {}
    
    public func save(_ willPower: WillPower) async throws {
        // インメモリ保存（実際の実装ではCore DataやUserDefaultsを使用）
        storedWillPower = WillPower(
            currentValue: willPower.currentValue,
            maxValue: willPower.maxValue
        )
    }
    
    public func load() async throws -> WillPower {
        guard let stored = storedWillPower else {
            throw RepositoryError.dataNotFound
        }
        
        return WillPower(
            currentValue: stored.currentValue,
            maxValue: stored.maxValue
        )
    }
    
    public func createDefault() -> WillPower {
        return WillPower(currentValue: 100, maxValue: 100)
    }
}

/// UserDefaultsを使用したWillPowerRepository実装
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
        let currentValue = userDefaults.integer(forKey: currentValueKey)
        let maxValue = userDefaults.integer(forKey: maxValueKey)
        
        // 初回起動時のデフォルト値設定
        if maxValue == 0 {
            return createDefault()
        }
        
        return WillPower(currentValue: currentValue, maxValue: maxValue)
    }
    
    public func createDefault() -> WillPower {
        return WillPower(currentValue: 100, maxValue: 100)
    }
}