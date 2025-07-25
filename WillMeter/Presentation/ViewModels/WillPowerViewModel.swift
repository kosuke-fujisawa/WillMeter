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
import SwiftUI

@MainActor
public class WillPowerViewModel: ObservableObject {
    private let willPowerUseCase: WillPowerUseCase
    private let localizationService: LocalizationService
    private var observableWillPower: ObservableWillPower?

    public init(
        willPowerUseCase: WillPowerUseCase,
        localizationService: LocalizationService = SwiftUILocalizationService()
    ) {
        self.willPowerUseCase = willPowerUseCase
        self.localizationService = localizationService

        // 言語変更監視（SwiftUILocalizationServiceの場合）
        if let swiftUIService = localizationService as? SwiftUILocalizationService {
            swiftUIService.objectWillChange
                .sink { [weak self] in
                    self?.objectWillChange.send()
                }
                .store(in: &cancellables)
        }

        // WillPowerデータの初期ロード
        _Concurrency.Task {
            await loadWillPower()
        }
    }

    private var cancellables = Set<AnyCancellable>()

    /// WillPowerデータをUseCaseから読み込み
    private func loadWillPower() async {
        do {
            let loadedObservableWillPower = try await willPowerUseCase.loadWillPower()
            self.observableWillPower = loadedObservableWillPower

            // インフラ層のObservableWillPowerの変更を監視してUI更新
            loadedObservableWillPower.objectWillChange
                .sink { [weak self] in
                    self?.objectWillChange.send()
                }
                .store(in: &cancellables)

            // UI更新通知
            objectWillChange.send()
        } catch {
            // エラーログ出力（本番環境では適切なログシステムを使用）
            print("Failed to load WillPower: \(error)")
            // エラー時はデフォルト値で初期化
            let defaultWillPower = WillPower(currentValue: 100, maxValue: 100)
            self.observableWillPower = ObservableWillPower(defaultWillPower)
            objectWillChange.send()
        }
    }

    // MARK: - ドメインエンティティへの読み取り専用アクセス

    public var currentValue: Int {
        observableWillPower?.currentValue ?? 0
    }

    public var maxValue: Int {
        observableWillPower?.maxValue ?? 100
    }

    public var percentage: Double {
        observableWillPower?.percentage ?? 0.0
    }

    public var status: WillPowerStatus {
        observableWillPower?.status ?? .critical
    }

    // MARK: - ユーザーアクション（UseCaseを経由したドメインロジック実行）

    @discardableResult
    public func consumeWillPower(amount: Int) -> Bool {
        guard let willPower = observableWillPower else {
            return false
        }
        let success = willPower.consume(amount: amount)
        if success {
            autoSave()
        }
        return success
    }

    public func restoreWillPower(amount: Int) {
        guard let willPower = observableWillPower else {
            return
        }
        willPower.restore(amount: amount)
        autoSave()
    }

    public func resetWillPower() {
        guard let willPower = observableWillPower else {
            return
        }
        willPower.reset()
        autoSave()
    }

    /// 変更をUseCaseを通じて自動保存
    private func autoSave() {
        guard let willPower = observableWillPower else {
            return
        }
        _Concurrency.Task {
            await willPowerUseCase.autoSave(willPower)
        }
    }

    // MARK: - Task Related Methods

    public func canPerformTask(_ task: Task) -> Bool {
        guard let willPower = observableWillPower else {
            return false
        }
        return willPower.canPerformTask(cost: task.willPowerCost)
    }

    @discardableResult
    public func performTask(_ task: Task) -> Bool {
        guard let willPower = observableWillPower else {
            return false
        }
        guard canPerformTask(task) else {
            return false
        }

        let success = willPower.consume(amount: task.willPowerCost)
        if success {
            task.markAsCompleted()
            autoSave()
        }
        return success
    }

    // MARK: - Computed Properties for UI

    public var displayText: String {
        return "\(currentValue) / \(maxValue)"
    }

    public var statusText: String {
        let statusDisplayName = localizedStatusDisplayName
        return "\(statusDisplayName) (\(Int(percentage * 100))%)"
    }

    private var localizedStatusDisplayName: String {
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

    public var statusColor: String {
        switch status {
        case .high: return "green"
        case .medium: return "yellow"
        case .low: return "orange"
        case .critical: return "red"
        }
    }

    public var isLowWillPower: Bool {
        return status == .low || status == .critical
    }

    public var isCriticalWillPower: Bool {
        return status == .critical
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

    public func getSuggestedTasks(from tasks: [Task]) -> [Task] {
        return tasks
            .filter { task in
                canPerformTask(task)
            }
            .sorted { task1, task2 in
                // Priority based sorting
                if task1.priority.rawValue != task2.priority.rawValue {
                    return task1.priority.rawValue > task2.priority.rawValue
                }
                // If same priority, sort by will power cost (ascending)
                return task1.willPowerCost < task2.willPowerCost
            }
    }
}
