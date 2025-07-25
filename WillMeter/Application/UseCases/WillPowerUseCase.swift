//
// WillPowerUseCase.swift
// WillMeter
//
// アプリケーション層：WillPowerに関するビジネスフロー

import Foundation

/// WillPowerに関するアプリケーション固有のビジネスフローを管理
/// アプリケーション層の責務：ドメインサービスとインフラの調整
public class WillPowerUseCase {
    private let repository: WillPowerRepository

    public init(repository: WillPowerRepository) {
        self.repository = repository
    }

    /// WillPowerを読み込み、ObservableWillPowerとして返す
    /// - Returns: UI向けのObservableWillPower
    /// - Throws: 読み込みに失敗した場合のエラー
    public func loadWillPower() async throws -> ObservableWillPower {
        do {
            let willPower = try await repository.load()
            return ObservableWillPower(willPower)
        } catch RepositoryError.dataNotFound {
            // データがない場合はデフォルトを作成
            let defaultWillPower = repository.createDefault()
            return ObservableWillPower(defaultWillPower)
        } catch {
            throw error
        }
    }

    /// ObservableWillPowerを保存する
    /// - Parameter observableWillPower: 保存するObservableWillPower
    /// - Throws: 保存に失敗した場合のエラー
    public func saveWillPower(_ observableWillPower: ObservableWillPower) async throws {
        // インフラ層のObservableWillPowerからドメインエンティティを取得
        let willPower = WillPower(
            currentValue: observableWillPower.currentValue,
            maxValue: observableWillPower.maxValue
        )
        try await repository.save(willPower)
    }

    /// 定期的な自動保存を実行
    /// - Parameter observableWillPower: 保存するObservableWillPower
    public func autoSave(_ observableWillPower: ObservableWillPower) async {
        do {
            try await saveWillPower(observableWillPower)
        } catch {
            // ログ出力やエラーハンドリング
            print("Auto-save failed: \(error)")
        }
    }
}
