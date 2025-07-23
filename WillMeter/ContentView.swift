import SwiftUI

struct ContentView: View {
    @StateObject private var willPowerViewModel = WillPowerViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                WillPowerDisplayView(viewModel: willPowerViewModel)

                Spacer()

                VStack(spacing: 15) {
                    Button("ウィルパワーを消費 (-20)") {
                        willPowerViewModel.consumeWillPower(amount: 20)
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityLabel("意志力を20ポイント消費")
                    .accessibilityHint("現在の意志力から20ポイントを減らします")

                    Button("ウィルパワーを回復 (+20)") {
                        willPowerViewModel.restoreWillPower(amount: 20)
                    }
                    .buttonStyle(.bordered)
                    .accessibilityLabel("意志力を20ポイント回復")
                    .accessibilityHint("現在の意志力に20ポイントを追加します")

                    Button("リセット") {
                        willPowerViewModel.resetWillPower()
                    }
                    .buttonStyle(.bordered)
                    .accessibilityLabel("意志力をリセット")
                    .accessibilityHint("意志力を最大値に戻します")
                }

                Spacer()
            }
            .padding()
            .navigationTitle("WillMeter")
        }
    }
}

struct WillPowerDisplayView: View {
    @ObservedObject var viewModel: WillPowerViewModel

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

                    Text(viewModel.status.displayName)
                        .font(.title3)
                        .foregroundStyle(Color(viewModel.statusColor))
                        .fontWeight(.semibold)
                }
            }
            .frame(width: 200, height: 200)

            // Status Information
            VStack(spacing: 10) {
                Text("現在の状態: \(viewModel.statusText)")
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
