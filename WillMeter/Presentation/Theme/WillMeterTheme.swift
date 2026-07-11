//
// WillMeterTheme.swift
// WillMeter
//
// Created by WillMeter Project
// Licensed under CC BY-NC 4.0
// https://creativecommons.org/licenses/by-nc/4.0/
//

import SwiftUI

/// アプリ全体の見た目(色・サイズ等)を集約する定義
/// UIデザインを差し替える場合は、このファイルの変更のみで対応できるようにする
public enum WillMeterTheme {
    /// ウィルパワーの状態に応じた色
    public static func statusColor(for status: WillPowerStatus) -> Color {
        switch status {
        case .high: return .green
        case .medium: return .yellow
        case .low: return .orange
        case .critical: return .red
        }
    }

    /// ウィルパワーゲージの見た目
    public enum Gauge {
        public static let size: CGFloat = 200
        public static let lineWidth: CGFloat = 15
        public static let trackOpacity: Double = 0.3
    }

    /// 言語選択行の見た目
    public enum LanguageRow {
        public static let cornerRadius: CGFloat = 12
        public static let selectedBackgroundOpacity: Double = 0.1
        public static let unselectedBorderOpacity: Double = 0.3
        public static let borderWidth: CGFloat = 1
    }
}
