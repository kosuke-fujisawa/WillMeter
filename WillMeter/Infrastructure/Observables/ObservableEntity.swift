//
// ObservableEntity.swift
// WillMeter
//
// Created by WillMeter Project
// Licensed under CC BY-NC 4.0
// https://creativecommons.org/licenses/by-nc/4.0/
//

import Foundation
import SwiftUI

/// ドメインエンティティをObservableObjectとしてラップする汎用クラス
/// インフラ層の責務：UI統合とリアクティブな状態管理
public class ObservableEntity<T>: ObservableObject {
    @Published private(set) var entity: T

    public init(_ entity: T) {
        self.entity = entity
    }

    /// エンティティを更新し、UI変更を通知
    public func update(_ updater: (inout T) -> Void) {
        updater(&entity)
        objectWillChange.send()
    }

    /// エンティティを置き換え、UI変更を通知
    public func replace(with newEntity: T) {
        entity = newEntity
        objectWillChange.send()
    }

    /// 現在のエンティティへの読み取り専用アクセス
    public var current: T {
        return entity
    }
}
