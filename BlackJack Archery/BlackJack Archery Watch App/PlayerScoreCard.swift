//
//  PlayerScoreCard.swift
//  BlackJack Archery
//
//  Created by Hunter Hartline on 5/7/26.
//

import SwiftUI

struct PlayerScoreCard: View {
    let player: Player
    let positionText: String
    let playerCount: Int
    let selectedPlayerIndex: Int

    let onIncrement: () -> Void
    let onDecrement: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 6) {
                VStack(alignment: .leading, spacing: 1) {
                    Text(player.initials)
                        .font(.system(size: 20, weight: .semibold))
                        .monospaced()
                        .foregroundStyle(.white.opacity(0.92))
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                    Text(positionText)
                        .font(.system(size: 9, weight: .regular))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }

                Spacer(minLength: 4)

                StatusBadge(status: player.status)
            }

            HStack(spacing: 11) {
                ScoreButton(
                    systemName: "minus",
                    action: onDecrement,
                    isPrimary: false
                )

                Text("\(player.score)")
                    .font(.system(size: 48, weight: .semibold))
                    .monospacedDigit()
                    .foregroundStyle(scoreColor)
                    .contentTransition(.numericText())
                    .minimumScaleFactor(0.72)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)

                ScoreButton(
                    systemName: "plus",
                    action: onIncrement,
                    isPrimary: true
                )
            }

            VStack(spacing: 2) {
                HStack {
                    Text(progressText)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    Spacer(minLength: 4)

                    Text("\(Player.targetScore)")
                        .font(.system(size: 9, weight: .medium))
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }

                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.1))

                        Capsule()
                            .fill(scoreColor.opacity(0.72))
                            .frame(
                                width: max(3, proxy.size.width * progressFraction)
                            )
                    }
                }
                .frame(height: 3)
            }

            PlayerPageDots(
                count: playerCount,
                selectedIndex: selectedPlayerIndex
            )
        }
        .frame(maxWidth: .infinity)
        .frame(height: 128)
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(cardBackground)
        .overlay(cardBorder)
        .animation(scoreAnimation, value: player.score)
        .animation(statusAnimation, value: player.status)
    }

    private var scoreAnimation: Animation? {
        reduceMotion ? nil : .spring(response: 0.2, dampingFraction: 0.86)
    }

    private var statusAnimation: Animation? {
        reduceMotion ? nil : .easeInOut(duration: 0.16)
    }

    private var progressText: String {
        switch player.status {
        case .playing:
            let remaining = max(Player.targetScore - player.score, 0)
            return "\(remaining) to \(Player.targetScore)"
        case .exact:
            return "Exact"
        case .bust:
            return "\(player.score - Player.targetScore) over"
        }
    }

    private var progressFraction: CGFloat {
        let cappedScore = min(max(player.score, 0), Player.targetScore)
        return CGFloat(cappedScore) / CGFloat(Player.targetScore)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(cardFillColor)
    }

    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .strokeBorder(borderColor, lineWidth: 1)
    }

    private var scoreColor: Color {
        switch player.status {
        case .playing:
            return Color(red: 0.56, green: 0.78, blue: 0.74)
        case .exact:
            return .yellow
        case .bust:
            return .red
        }
    }

    private var borderColor: Color {
        switch player.status {
        case .playing:
            return .white.opacity(0.12)
        case .exact:
            return .yellow.opacity(0.48)
        case .bust:
            return .red.opacity(0.48)
        }
    }

    private var cardFillColor: Color {
        switch player.status {
        case .playing:
            return .white.opacity(0.07)
        case .exact:
            return .yellow.opacity(0.08)
        case .bust:
            return .red.opacity(0.08)
        }
    }
}
