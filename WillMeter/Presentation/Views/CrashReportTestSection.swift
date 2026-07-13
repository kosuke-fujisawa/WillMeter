//
// CrashReportTestSection.swift
// WillMeter
//
// Created by WillMeter Project
// Licensed under CC BY-NC 4.0
// https://creativecommons.org/licenses/by-nc/4.0/
//

#if CRASH_REPORT_TESTING
import SwiftUI

/// TestFlightでApple標準のクラッシュレポート収集を確認する検証専用UI
struct CrashReportTestSection: View {
    @State private var isShowingConfirmation = false

    var body: some View {
        Button("クラッシュレポートを検証", role: .destructive) {
            isShowingConfirmation = true
        }
        .buttonStyle(.bordered)
        .accessibilityIdentifier("crashReportTestButton")
        .confirmationDialog(
            "アプリを意図的にクラッシュさせますか？",
            isPresented: $isShowingConfirmation,
            titleVisibility: .visible
        ) {
            Button("クラッシュさせる", role: .destructive) {
                fatalError("Intentional crash for TestFlight crash report verification")
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("この操作はクラッシュレポート検証用TestFlightビルドでのみ使用してください。")
        }
    }
}
#endif
