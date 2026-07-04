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
/// RepositoryUtilsを使用し共通処理を利用
public class InMemoryWillPowerRepository: WillPowerRepository {
    private var storedWillPower: WillPower?

    public init() {}

    public func save(_ willPower: WillPower) async throws {
        // 共通ヘルパーを使用してコピー作成
        storedWillPower = RepositoryUtils.copyWillPower(willPower)
    }

    public func load() async throws -> WillPower {
        guard let stored = storedWillPower else {
            throw RepositoryError.dataNotFound
        }

        // 共通ヘルパーを使用してコピー作成
        return RepositoryUtils.copyWillPower(stored)
    }

    public func createDefault() -> WillPower {
        // 共通ヘルパーを使用
        return RepositoryUtils.createDefaultWillPower()
    }
}
