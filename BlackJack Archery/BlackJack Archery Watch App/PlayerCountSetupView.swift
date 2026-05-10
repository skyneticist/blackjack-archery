//
//  PlayerCountSetupView.swift
//  BlackJack Archery
//
//  Created by Hunter Hartline on 5/7/26.
//

import SwiftUI

struct PlayerCountSetupView: View {
    @Binding var playerCount: Int

    let hasGameHistory: Bool
    let onStart: () -> Void
    let onShowHistory: () -> Void

    @State private var crownValue: Double = 3
    @FocusState private var isCrownFocused: Bool

    var body: some View {
        VStack(spacing: 7) {
            Text("Archery 21")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(PlayerCountPalette.gold)

            Text("Players")
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                CountAdjustmentButton(
                    systemImage: "minus",
                    isDisabled: playerCount <= 1
                ) {
                    playerCount = max(1, playerCount - 1)
                }

                Text("\(playerCount)")
                    .font(.system(size: 52, weight: .semibold))
                    .monospacedDigit()
                    .foregroundStyle(Color(red: 0.56, green: 0.78, blue: 0.74))

                CountAdjustmentButton(
                    systemImage: "plus",
                    isDisabled: playerCount >= 8
                ) {
                    playerCount = min(8, playerCount + 1)
                }
            }

            HStack(spacing: 6) {
                Button {
                    onStart()
                } label: {
                    PlayerCountStartLabel(isCompact: hasGameHistory)
                }
                .buttonStyle(.plain)

                if hasGameHistory {
                    Button {
                        onShowHistory()
                    } label: {
                        PlayerCountHistoryLabel()
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .focusable(true)
        .focused($isCrownFocused)
        .digitalCrownRotation(
            $crownValue,
            from: 1,
            through: 8,
            by: 1,
            sensitivity: .medium,
            isContinuous: false,
            isHapticFeedbackEnabled: true
        )
        .onChange(of: crownValue) { _, newValue in
            updatePlayerCount(from: newValue)
        }
        .onChange(of: playerCount) { _, newValue in
            let roundedCrownValue = Int(crownValue.rounded())

            if roundedCrownValue != newValue {
                crownValue = Double(newValue)
            }
        }
        .onAppear {
            let playerCountValue = Double(playerCount)

            if crownValue != playerCountValue {
                crownValue = playerCountValue
            }

            DispatchQueue.main.async {
                if !isCrownFocused {
                    isCrownFocused = true
                }
            }
        }
        .onDisappear {
            isCrownFocused = false
        }
    }

    private func updatePlayerCount(from newValue: Double) {
        let newCount = min(max(Int(newValue.rounded()), 1), 8)

        if newCount != playerCount {
            playerCount = newCount
        }
    }
}

private enum PlayerCountPalette {
    static let gold = Color(red: 0.98, green: 0.72, blue: 0.27)
}

private struct CountAdjustmentButton: View {
    let systemImage: String
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button {
            guard !isDisabled else {
                return
            }

            action()
        } label: {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white.opacity(isDisabled ? 0.28 : 0.86))
                .frame(width: 36, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.white.opacity(isDisabled ? 0.04 : 0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .strokeBorder(Color.white.opacity(isDisabled ? 0.06 : 0.12), lineWidth: 1)
                )
                .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}

private struct PlayerCountStartLabel: View {
    let isCompact: Bool

    var body: some View {
        Text("Start")
            .font(.system(size: 13, weight: .semibold))
            .lineLimit(1)
            .foregroundStyle(.black)
            .frame(width: isCompact ? 68 : 82, height: 32)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(PlayerCountPalette.gold)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct PlayerCountHistoryLabel: View {
    var body: some View {
        Label("History", systemImage: "clock.arrow.circlepath")
            .font(.system(size: 11, weight: .semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.76)
            .foregroundStyle(.white.opacity(0.9))
            .frame(width: 70, height: 32)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
