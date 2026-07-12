//
// WillPowerViewModel.swift
// WillMeter
//
// Created by WillMeter Project
// Licensed under CC BY-NC 4.0
// https://creativecommons.org/licenses/by-nc/4.0/
//

import Combine
import Foundation
import OSLog
import SwiftUI

@MainActor
public class WillPowerViewModel: ObservableObject {
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "WillMeter", category: "WillPower")

    private let willPowerUseCase: WillPowerUseCase
    private let localizationService: SwiftUILocalizationService
    private var willPower: WillPower?

    public init(
        willPowerUseCase: WillPowerUseCase,
        localizationService: SwiftUILocalizationService = SwiftUILocalizationService()
    ) {
        self.willPowerUseCase = willPowerUseCase
        self.localizationService = localizationService

        localizationService.objectWillChange
            .sink { [weak self] in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    private var cancellables = Set<AnyCancellable>()
    private var isLoaded = false
    private var pendingSaveTask: _Concurrency.Task<Void, Never>?

    /// 保存/読み込み失敗時にユーザーへ提示するエラーメッセージ
    @Published public private(set) var errorMessage: String?

    /// エラーメッセージを消去する
    public func dismissError() {
        errorMessage = nil
    }

    /// テスト用: 直前のautoSaveの完了を待機する
    func waitForPendingSaveForTesting() async {
        await pendingSaveTask?.value
    }

    /// WillPowerデータをUseCaseから読み込み（多重呼び出し時は初回のみ実行）
    func load() async {
        guard !isLoaded else {
            return
        }
        isLoaded = true

        do {
            setWillPower(try await willPowerUseCase.loadWillPower())
        } catch {
            Self.logger.error("Failed to load WillPower: \(error.localizedDescription, privacy: .public)")
            setWillPower(WillPower.makeDefault())
            errorMessage = localizationService.localizedString(for: LocalizationKeys.Error.loadFailed)
            // 次回呼び出し時に再ロードできるようガードを解除
            isLoaded = false
        }
    }

    private func setWillPower(_ willPower: WillPower) {
        self.willPower = willPower
        willPower.addObserver { [weak self] _ in
            DispatchQueue.main.async {
                self?.objectWillChange.send()
            }
        }
        objectWillChange.send()
    }

    // MARK: - ドメインエンティティへの読み取り専用アクセス

    public var currentValue: Int {
        willPower?.currentValue ?? 0
    }

    public var maxValue: Int {
        willPower?.maxValue ?? WillPower.defaultMaxValue
    }

    public var percentage: Double {
        willPower?.percentage ?? 0.0
    }

    public var status: WillPowerStatus {
        willPower?.status ?? .critical
    }

    // MARK: - ユーザーアクション（UseCaseを経由したドメインロジック実行）

    @discardableResult
    public func consumeWillPower(amount: Int) -> Bool {
        guard let willPower else {
            return false
        }
        let success = willPower.consume(amount: amount)
        if success {
            autoSave()
        }
        return success
    }

    public func restoreWillPower(amount: Int) {
        guard let willPower else {
            return
        }
        willPower.restore(amount: amount)
        autoSave()
    }

    public func resetWillPower() {
        guard let willPower else {
            return
        }
        willPower.reset()
        autoSave()
    }

    /// 変更をUseCaseを通じて自動保存し、失敗時はエラーメッセージを表示する
    private func autoSave() {
        guard let willPower else {
            return
        }
        pendingSaveTask = _Concurrency.Task {
            do {
                try await willPowerUseCase.saveWillPower(willPower)
                errorMessage = nil
            } catch {
                Self.logger.error("Auto-save failed: \(error.localizedDescription, privacy: .public)")
                errorMessage = localizationService.localizedString(for: LocalizationKeys.Error.saveFailed)
            }
        }
    }

    // MARK: - Computed Properties for UI

    public var displayText: String {
        return "\(currentValue) / \(maxValue)"
    }

    public var statusText: String {
        let statusDisplayName = localizedStatusDisplayName
        return "\(statusDisplayName) (\(Int(percentage * 100))%)"
    }

    /// 状態を表す短い表示名（例: 「最高」）。ゲージ内表示等、パーセンテージを含めない箇所で使用する
    public var localizedStatusDisplayName: String {
        switch status {
        case .high:
            return localizationService.localizedString(for: LocalizationKeys.WillPower.Status.excellent)
        case .medium:
            return localizationService.localizedString(for: LocalizationKeys.WillPower.Status.good)
        case .low:
            return localizationService.localizedString(for: LocalizationKeys.WillPower.Status.low)
        case .critical:
            return localizationService.localizedString(for: LocalizationKeys.WillPower.Status.critical)
        }
    }

    // MARK: - Recommendations

    public var recommendedAction: String {
        switch status {
        case .high:
            return localizationService.localizedString(for: LocalizationKeys.Recommendation.excellent)
        case .medium:
            return localizationService.localizedString(for: LocalizationKeys.Recommendation.good)
        case .low:
            return localizationService.localizedString(for: LocalizationKeys.Recommendation.low)
        case .critical:
            return localizationService.localizedString(for: LocalizationKeys.Recommendation.critical)
        }
    }
}
