//
// BaseRepository.swift
// WillMeter
//
// Created by WillMeter Project
// Licensed under CC BY-NC 4.0
// https://creativecommons.org/licenses/by-nc/4.0/
//

import Foundation

/// Repository実装の共通ユーティリティ
/// インフラ層の責務：永続化の共通処理と定数定義
public struct RepositoryUtils {
    // MARK: - 共通定数

    /// デフォルトWillPower設定
    public struct DefaultWillPower {
        public static let currentValue = 100
        public static let maxValue = 100
    }

    // MARK: - 共通ヘルパーメソッド

    /// デフォルトWillPowerエンティティを作成
    /// - Returns: デフォルト設定のWillPowerエンティティ
    public static func createDefaultWillPower() -> WillPower {
        return WillPower(
            currentValue: DefaultWillPower.currentValue,
            maxValue: DefaultWillPower.maxValue
        )
    }

    /// WillPowerエンティティをコピーして新しいインスタンスを作成
    /// - Parameter willPower: コピー元のWillPower
    /// - Returns: 新しいWillPowerインスタンス
    public static func copyWillPower(_ willPower: WillPower) -> WillPower {
        return WillPower(
            currentValue: willPower.currentValue,
            maxValue: willPower.maxValue
        )
    }
}
