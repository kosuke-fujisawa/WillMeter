//
// ObserverList.swift
// WillMeter
//
// Created by WillMeter Project
// Licensed under CC BY-NC 4.0
// https://creativecommons.org/licenses/by-nc/4.0/
//

import Foundation

/// ドメインエンティティ共通の観察者パターン実装
final class ObserverList<T> {
    private var observers: [(T) -> Void] = []

    func add(_ observer: @escaping (T) -> Void) {
        observers.append(observer)
    }

    func notify(_ value: T) {
        observers.forEach { $0(value) }
    }
}
