//
// WillPowerRepository.swift
// WillMeter
//
// Created by WillMeter Project
// Licensed under CC BY-NC 4.0
// https://creativecommons.org/licenses/by-nc/4.0/
//

import Foundation

/// WillPowerエンティティの永続化を抽象化するRepository
/// ドメイン層の責務：データアクセスの抽象化（実装はインフラ層）
public protocol WillPowerRepository: Sendable {
    /// WillPowerエンティティを保存する
    /// - Parameter willPower: 保存するWillPowerエンティティ
    /// - Throws: 保存に失敗した場合のエラー
    func save(_ willPower: WillPower) async throws

    /// WillPowerエンティティを読み込む
    /// - Returns: 読み込んだWillPowerエンティティ
    /// - Throws: 読み込みに失敗した場合のエラー
    func load() async throws -> WillPower

    /// デフォルトのWillPowerエンティティを作成する
    /// - Returns: デフォルト設定のWillPowerエンティティ
    func createDefault() -> WillPower
}

/// Repository実装のエラー
public enum RepositoryError: Error, LocalizedError {
    case dataNotFound
    case saveFailed(underlying: Error)
    case loadFailed(underlying: Error)
    case invalidData

    public var errorDescription: String? {
        switch self {
        case .dataNotFound:
            return "データが見つかりません"
        case .saveFailed(let error):
            return "保存に失敗しました: \(error.localizedDescription)"
        case .loadFailed(let error):
            return "読み込みに失敗しました: \(error.localizedDescription)"
        case .invalidData:
            return "無効なデータです"
        }
    }
}
