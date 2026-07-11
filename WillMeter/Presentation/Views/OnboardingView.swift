//
// OnboardingView.swift
// WillMeter
//
// Created by WillMeter Project
// Licensed under CC BY-NC 4.0
// https://creativecommons.org/licenses/by-nc/4.0/
//

import SwiftUI

/// 初回起動時にアプリの目的・基本操作を説明するオンボーディング画面
struct OnboardingView: View {
    @EnvironmentObject var localizationService: SwiftUILocalizationService
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "gauge.with.dots.needle.67percent")
                .font(.system(size: 64))
                .foregroundStyle(.blue)

            VStack(spacing: 12) {
                Text(localizationService.localizedString(for: LocalizationKeys.Onboarding.title))
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text(localizationService.localizedString(for: LocalizationKeys.Onboarding.description))
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            VStack(alignment: .leading, spacing: 16) {
                Text(localizationService.localizedString(for: LocalizationKeys.Onboarding.howToTitle))
                    .font(.headline)

                OnboardingStepRow(
                    systemImage: "minus.circle.fill",
                    color: .blue,
                    text: localizationService.localizedString(for: LocalizationKeys.Onboarding.howToConsume)
                )
                OnboardingStepRow(
                    systemImage: "plus.circle.fill",
                    color: .green,
                    text: localizationService.localizedString(for: LocalizationKeys.Onboarding.howToRestore)
                )
                OnboardingStepRow(
                    systemImage: "arrow.counterclockwise.circle.fill",
                    color: .orange,
                    text: localizationService.localizedString(for: LocalizationKeys.Onboarding.howToReset)
                )
            }
            .padding(.horizontal, 32)

            Spacer()

            Button(action: onStart) {
                Text(localizationService.localizedString(for: LocalizationKeys.Onboarding.startButton))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal, 32)
            .padding(.bottom, 24)
        }
    }
}

/// オンボーディングの使い方説明1行分
private struct OnboardingStepRow: View {
    let systemImage: String
    let color: Color
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: systemImage)
                .foregroundStyle(color)
                .frame(width: 24)

            Text(text)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    OnboardingView {}
        .environmentObject(SwiftUILocalizationService())
}
