//
// WillPowerUseCase.swift
// WillMeter
//
// Created by WillMeter Project
// Licensed under CC BY-NC 4.0
// https://creativecommons.org/licenses/by-nc/4.0/
//

import Foundation

/// WillPowerに関するアプリケーション固有のビジネスフローを管理
/// アプリケーション層の責務：ドメインサービスとインフラの調整
public class WillPowerUseCase {
    private let repository: WillPowerRepository

    public init(repository: WillPowerRepository) {
        self.repository = repository
    }

    /// WillPowerを読み込む
    /// - Throws: 読み込みに失敗した場合のエラー
    public func loadWillPower() async throws -> WillPower {
        try await repository.load()
    }

    /// WillPowerを保存する
    /// - Throws: 保存に失敗した場合のエラー
    public func saveWillPower(_ willPower: WillPower) async throws {
        try await repository.save(willPower)
    }
}
