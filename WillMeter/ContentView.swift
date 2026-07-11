//
// ContentView.swift
// WillMeter
//
// Created by WillMeter Project
// Licensed under CC BY-NC 4.0
// https://creativecommons.org/licenses/by-nc/4.0/
//

import SwiftUI

struct ContentView: View {
    @StateObject private var localizationService: SwiftUILocalizationService
    @StateObject private var willPowerViewModel: WillPowerViewModel
    @State private var showLanguageSettings = false

    private let willPowerStepAmount = 20

    init() {
        let service = SwiftUILocalizationService()
        self._localizationService = StateObject(wrappedValue: service)

        // リポジトリとUseCaseの初期化
        let repository = UserDefaultsWillPowerRepository()
        let useCase = WillPowerUseCase(repository: repository)
        self._willPowerViewModel = StateObject(
            wrappedValue: WillPowerViewModel(
                willPowerUseCase: useCase,
                localizationService: service
            )
        )
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                WillPowerDisplayView(viewModel: willPowerViewModel)
                    .environmentObject(localizationService)

                Spacer()

                VStack(spacing: 15) {
                    Button(
                        localizationService.localizedString(
                            for: LocalizationKeys.WillPower.Action.consume,
                            arguments: willPowerStepAmount
                        )
                    ) {
                        willPowerViewModel.consumeWillPower(amount: willPowerStepAmount)
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityLabel(
                        localizationService.localizedString(
                            for: LocalizationKeys.WillPower.Action.consume,
                            arguments: willPowerStepAmount
                        )
                    )
                    .accessibilityHint(
                        localizationService.localizedString(
                            for: LocalizationKeys.UI.Accessibility.consumeHint,
                            arguments: willPowerStepAmount
                        )
                    )

                    Button(
                        localizationService.localizedString(
                            for: LocalizationKeys.WillPower.Action.restore,
                            arguments: willPowerStepAmount
                        )
                    ) {
                        willPowerViewModel.restoreWillPower(amount: willPowerStepAmount)
                    }
                    .buttonStyle(.bordered)
                    .accessibilityLabel(
                        localizationService.localizedString(
                            for: LocalizationKeys.WillPower.Action.restore,
                            arguments: willPowerStepAmount
                        )
                    )
                    .accessibilityHint(
                        localizationService.localizedString(
                            for: LocalizationKeys.UI.Accessibility.restoreHint,
                            arguments: willPowerStepAmount
                        )
                    )

                    Button(localizationService.localizedString(for: LocalizationKeys.WillPower.Action.reset)) {
                        willPowerViewModel.resetWillPower()
                    }
                    .buttonStyle(.bordered)
                    .accessibilityLabel(
                        localizationService.localizedString(for: LocalizationKeys.WillPower.Action.reset)
                    )
                    .accessibilityHint(
                        localizationService.localizedString(for: LocalizationKeys.UI.Accessibility.resetHint)
                    )
                }

                Spacer()
            }
            .padding()
            .navigationTitle(localizationService.localizedString(for: LocalizationKeys.UI.appTitle))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showLanguageSettings = true
                    } label: {
                        Image(systemName: "globe")
                    }
                    .accessibilityLabel(
                        localizationService.localizedString(for: LocalizationKeys.UI.Accessibility.languageButton)
                    )
                    .accessibilityHint(
                        localizationService.localizedString(for: LocalizationKeys.UI.Accessibility.languageButtonHint)
                    )
                }
            }
            .sheet(isPresented: $showLanguageSettings) {
                LanguageSettingsView()
                    .environmentObject(localizationService)
            }
        }
        .task {
            await willPowerViewModel.load()
        }
    }
}

struct WillPowerDisplayView: View {
    @ObservedObject var viewModel: WillPowerViewModel
    @EnvironmentObject var localizationService: SwiftUILocalizationService

    var body: some View {
        VStack(spacing: 20) {
            // Will Power Gauge
            ZStack {
                Circle()
                    .stroke(lineWidth: 15)
                    .opacity(0.3)
                    .foregroundStyle(.gray)

                Circle()
                    .trim(from: 0.0, to: viewModel.percentage)
                    .stroke(style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round))
                    .foregroundStyle(Color(viewModel.statusColor))
                    .rotationEffect(Angle(degrees: 270))
                    .animation(.easeInOut(duration: 0.5), value: viewModel.percentage)

                VStack {
                    Text("\(viewModel.currentValue)")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("/ \(viewModel.maxValue)")
                        .font(.title2)
                        .foregroundStyle(.secondary)

                    Text(localizationService.localizedString(for: viewModel.status.localizationKey))
                        .font(.title3)
                        .foregroundStyle(Color(viewModel.statusColor))
                        .fontWeight(.semibold)
                }
            }
            .frame(width: 200, height: 200)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(localizationService.localizedString(for: LocalizationKeys.WillPower.title))
            .accessibilityValue("\(viewModel.displayText), \(viewModel.statusText)")

            // Status Information
            VStack(spacing: 10) {
                Text(
                    "\(localizationService.localizedString(for: LocalizationKeys.UI.currentState)): " +
                    "\(viewModel.statusText)"
                )
                    .font(.headline)

                Text(viewModel.recommendedAction)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }
        }
    }
}

#Preview {
    ContentView()
}
