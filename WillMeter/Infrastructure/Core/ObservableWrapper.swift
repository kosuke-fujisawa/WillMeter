//
// ObservableWrapper.swift
// WillMeter
//
// Created by WillMeter Project
// Licensed under CC BY-NC 4.0
// https://creativecommons.org/licenses/by-nc/4.0/
//

import Foundation
import SwiftUI

/// Observer PatternをサポートするドメインエンティティをSwiftUIに統合するための汎用ラッパー
/// インフラ層の責務：ドメインエンティティとUI層の橋渡し
public class ObservableWrapper<T: Observable>: ObservableObject where T.ObserverType == T {
    @Published private var entity: T

    public init(_ entity: T) {
        self.entity = entity

        // ドメインエンティティの変更を監視してUI更新
        entity.addObserver { [weak self] _ in
            DispatchQueue.main.async {
                self?.objectWillChange.send()
            }
        }
    }

    /// ラップされたエンティティへの読み取り専用アクセス
    public var wrappedEntity: T {
        return entity
    }

    /// エンティティを更新し、必要に応じてUI変更を通知
    /// - Parameter updater: エンティティを更新するクロージャ
    public func update(_ updater: (T) -> Void) {
        updater(entity)
        // ドメインエンティティが自動的に通知するため、追加の通知は不要
    }

    /// エンティティを置き換え、UI変更を通知
    /// - Parameter newEntity: 新しいエンティティ
    public func replace(with newEntity: T) {
        entity = newEntity

        // 新しいエンティティの変更も監視
        newEntity.addObserver { [weak self] _ in
            DispatchQueue.main.async {
                self?.objectWillChange.send()
            }
        }

        objectWillChange.send()
    }
}
