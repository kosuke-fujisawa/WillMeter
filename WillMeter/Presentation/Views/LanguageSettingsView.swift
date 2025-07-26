//
//  LanguageSettingsView.swift
//  WillMeter
//
//  Created by WillMeter Project
//  Licensed under CC BY-NC 4.0
//  https://creativecommons.org/licenses/by-nc/4.0/
//

import SwiftUI

/// 言語設定画面
/// 動的言語切り替え機能を提供するプレゼンテーション層コンポーネント
struct LanguageSettingsView: View {
    @EnvironmentObject var localizationService: SwiftUILocalizationService
    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(localizationService.localizedString(for: "settings.language"))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)

                Spacer()

                VStack(spacing: 16) {
                    ForEach(localizationService.supportedLanguagesDisplayNames, id: \.code) { language in
                        LanguageSelectionRow(
                            languageCode: language.code,
                            displayName: language.name,
                            isSelected: localizationService.currentLanguageCode == language.code
                        ) {
                            localizationService.changeLanguage(to: language.code)
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer()

                // 現在の言語表示
                VStack(spacing: 8) {
                    Text(localizationService.localizedString(for: LocalizationKeys.Settings.currentLanguage))
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    Text(localizationService.currentLanguageDisplayName)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                }
                .padding(.bottom, 40)
            }
            .navigationTitle(localizationService.localizedString(for: LocalizationKeys.Settings.language))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(localizationService.localizedString(for: LocalizationKeys.UI.done)) {
                        dismiss()
                    }
                }
            }
        }
    }
}

/// 言語選択行コンポーネント
private struct LanguageSelectionRow: View {
    let languageCode: String
    let displayName: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(displayName)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(languageCode.uppercased())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.blue)
                        .font(.title2)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

/// 言語設定画面のプレビュー
#Preview {
    LanguageSettingsView()
        .environmentObject(SwiftUILocalizationService())
}
