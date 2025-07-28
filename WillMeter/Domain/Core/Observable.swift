//
// Observable.swift
// WillMeter
//
// Created by WillMeter Project
// Licensed under CC BY-NC 4.0
// https://creativecommons.org/licenses/by-nc/4.0/
//

import Foundation

/// ドメインエンティティのObserver Patternの共通プロトコル
public protocol Observable {
    associatedtype ObserverType

    /// 観察者を追加する
    /// - Parameter observer: 変更通知を受け取るクロージャ
    func addObserver(_ observer: @escaping (ObserverType) -> Void)

    /// すべての観察者に変更を通知する
    func notifyObservers()
}

/// Observer Patternの実装を提供するミックスイン
public class ObserverMixin<T> {
    private var observers: [(T) -> Void] = []

    /// 観察者を追加する
    /// - Parameter observer: 変更通知を受け取るクロージャ
    public func addObserver(_ observer: @escaping (T) -> Void) {
        observers.append(observer)
    }

    /// すべての観察者に変更を通知する
    /// - Parameter subject: 通知対象のオブジェクト
    public func notifyObservers(with subject: T) {
        observers.forEach { $0(subject) }
    }

    /// 観察者リストをクリアする（テスト用）
    public func clearObservers() {
        observers.removeAll()
    }

    /// 現在の観察者数を取得する（テスト用）
    public var observerCount: Int {
        return observers.count
    }
}
