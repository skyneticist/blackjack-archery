//
//  PlayerScoreCard.swift
//  BlackJack Archery
//
//  Created by Hunter Hartline on 5/7/26.
//

import SwiftUI

struct PlayerScoreCard: View {
    let player: Player
    let players: [Player]
    let positionText: String
    let playerCount: Int
    let selectedPlayerIndex: Int
    let selectionHighlight: Double

    let onIncrement: () -> Void
    let onDecrement: () -> Void

    @State private var isShowingScoreSummary = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let flipRotation = isShowingScoreSummary ? 180.0 : 0.0

        ZStack {
            cardFace {
                ZStack {
                    flipTapLayer
                    frontFace
                }
            }
            .modifier(FlipFaceVisibility(rotation: flipRotation, isFront: true))
            .allowsHitTesting(!isShowingScoreSummary)

            cardFace {
                ZStack {
                    flipTapLayer
                    scoreSummaryFace
                        .allowsHitTesting(false)
                }
            }
            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            .modifier(FlipFaceVisibility(rotation: flipRotation, isFront: false))
            .allowsHitTesting(isShowingScoreSummary)
        }
        .rotation3DEffect(
            .degrees(reduceMotion ? 0 : flipRotation),
            axis: (x: 0, y: 1, z: 0),
            perspective: 0.62
        )
        .animation(flipAnimation, value: isShowingScoreSummary)
    }

    private var frontFace: some View {
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
            .allowsHitTesting(false)

            scoreControls

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
            .allowsHitTesting(false)

            PlayerPageDots(
                count: playerCount,
                selectedIndex: selectedPlayerIndex
            )
            .allowsHitTesting(false)
        }
    }

    private var scoreSummaryFace: some View {
        let usesCompactRows = players.count > 4

        return VStack(spacing: 4) {
            HStack(spacing: 4) {
                Text("Scores 🎯")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.94))
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)

                Spacer(minLength: 3)

                Text("21 target")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(.black)
                    .lineLimit(1)
                    .padding(.horizontal, 6)
                    .frame(height: 15)
                    .background(
                        Capsule()
                            .fill(Color.yellow.opacity(0.92))
                    )
            }

            LazyVGrid(columns: scoreSummaryColumns, spacing: 4) {
                ForEach(Array(players.enumerated()), id: \.element.id) { index, scorePlayer in
                    ScoreSummaryRow(
                        player: scorePlayer,
                        position: index + 1,
                        isSelected: scorePlayer.id == player.id,
                        accentColor: scoreColor(for: scorePlayer.status),
                        isCompact: usesCompactRows
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var scoreControls: some View {
        ZStack {
            HStack(spacing: 8) {
                ScoreButton(
                    systemName: "minus",
                    action: onDecrement,
                    isPrimary: false
                )

                Text("\(player.score)")
                    .font(.system(size: 50, weight: .semibold))
                    .monospacedDigit()
                    .foregroundStyle(scoreColor)
                    .contentTransition(.numericText())
                    .minimumScaleFactor(0.46)
                    .lineLimit(1)
                    .allowsTightening(true)
                    .frame(maxWidth: .infinity)
                    .layoutPriority(1)
                    .allowsHitTesting(false)
                    .animation(scoreReadoutAnimation, value: player.score)

                ScoreButton(
                    systemName: "plus",
                    action: onIncrement,
                    isPrimary: true
                )
            }

            HStack {
                scoreAdjustmentHitArea(action: onDecrement)

                Spacer(minLength: 0)

                scoreAdjustmentHitArea(action: onIncrement)
            }
        }
    }

    private func scoreAdjustmentHitArea(action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Color.clear
                .frame(width: 44, height: 48)
                .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityHidden(true)
    }

    private var flipTapLayer: some View {
        Button {
            toggleScoreSummary()
        } label: {
            Color.clear
                .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isShowingScoreSummary ? "Show current player card" : "Show all scores")
    }

    private func cardFace<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .frame(maxWidth: .infinity)
            .frame(height: 128)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(cardBackground)
            .overlay(cardBorder)
    }

    private var flipAnimation: Animation? {
        reduceMotion ? nil : .easeInOut(duration: 0.32)
    }

    private var scoreReadoutAnimation: Animation? {
        reduceMotion ? nil : .spring(response: 0.16, dampingFraction: 0.9)
    }

    private func toggleScoreSummary() {
        isShowingScoreSummary.toggle()
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

    private var scoreSummaryColumns: [GridItem] {
        let columnCount = players.count > 4 ? 2 : 1

        return Array(
            repeating: GridItem(.flexible(), spacing: players.count > 4 ? 5 : 4),
            count: columnCount
        )
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(cardFillColor)
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(selectionHighlightColor.opacity(selectionHighlight * 0.035))
            )
    }

    private var cardBorder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(borderColor, lineWidth: 1)

            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(
                    selectionHighlightColor.opacity(selectionHighlight * 0.5),
                    lineWidth: 1 + CGFloat(selectionHighlight * 0.5)
                )

            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .inset(by: 2)
                .strokeBorder(
                    selectionHighlightColor.opacity(selectionHighlight * 0.16),
                    lineWidth: 1
                )
        }
    }

    private var scoreColor: Color {
        scoreColor(for: player.status)
    }

    private var selectionHighlightColor: Color {
        switch player.status {
        case .playing:
            return Color(red: 0.62, green: 0.9, blue: 0.84)
        case .exact:
            return Color(red: 1.0, green: 0.84, blue: 0.28)
        case .bust:
            return Color(red: 1.0, green: 0.34, blue: 0.32)
        }
    }

    private func scoreColor(for status: PlayerStatus) -> Color {
        switch status {
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

private struct ScoreSummaryRow: View {
    let player: Player
    let position: Int
    let isSelected: Bool
    let accentColor: Color
    let isCompact: Bool

    var body: some View {
        HStack(spacing: isCompact ? 3 : 4) {
            Text("\(position)")
                .font(.system(size: isCompact ? 8 : 9, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(isSelected ? .black : accentColor)
                .frame(
                    width: isCompact ? 15 : 16,
                    height: isCompact ? 15 : 16
                )
                .background(
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(isSelected ? accentColor : accentColor.opacity(0.14))
                )

            Text(player.initials)
                .font(.system(size: isCompact ? 10 : 11, weight: .semibold))
                .monospaced()
                .foregroundStyle(.white.opacity(isSelected ? 0.96 : 0.78))
                .lineLimit(1)
                .minimumScaleFactor(0.68)
                .layoutPriority(1)

            Spacer(minLength: 2)

            Text("\(player.score)")
                .font(.system(size: isCompact ? 14 : 15, weight: .semibold))
                .monospacedDigit()
                .foregroundStyle(accentColor)
                .lineLimit(1)
                .minimumScaleFactor(0.68)
        }
        .padding(.horizontal, isCompact ? 4 : 5)
        .frame(height: isCompact ? 23 : 24)
        .background(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(isSelected ? accentColor.opacity(0.18) : Color.white.opacity(0.055))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .strokeBorder(
                    isSelected ? accentColor.opacity(0.34) : Color.white.opacity(0.075),
                    lineWidth: 1
                )
        )
    }
}

private struct FlipFaceVisibility: AnimatableModifier {
    var rotation: Double
    let isFront: Bool

    var animatableData: Double {
        get { rotation }
        set { rotation = newValue }
    }

    func body(content: Content) -> some View {
        content.opacity(isFaceVisible ? 1 : 0)
    }

    private var isFaceVisible: Bool {
        isFront ? rotation < 90 : rotation >= 90
    }
}
