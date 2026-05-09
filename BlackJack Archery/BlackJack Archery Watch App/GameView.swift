//
//  GameView.swift
//  BlackJack Archery
//
//  Created by Hunter Hartline on 5/7/26.
//

import SwiftUI
import WatchKit

struct GameView: View {
    @Binding var gameState: GameState

    let onFinishGame: () -> Void
    let onNewGame: () -> Void

    @State private var crownValue: Double = 0
    @State private var isShowingGameActions = false
    @FocusState private var isCrownFocused: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var maximumCrownValue: Double {
        Double(max(gameState.players.count - 1, 0))
    }

    var body: some View {
        VStack(spacing: 5) {
            if let selectedPlayer = gameState.selectedPlayer {
                PlayerScoreCard(
                    player: selectedPlayer,
                    positionText: gameState.selectedPlayerPositionText,
                    playerCount: gameState.players.count,
                    selectedPlayerIndex: gameState.selectedPlayerIndex,
                    onIncrement: {
                        incrementSelectedPlayerScore()
                    },
                    onDecrement: {
                        decrementSelectedPlayerScore()
                    }
                )
                .id(selectedPlayer.id)
                .transition(.scale(scale: 0.97).combined(with: .opacity))

                BottomControlsSlot {
                    if isShowingGameActions {
                        GameActionsTray(
                            summaryText: gameState.makeResult().summaryText,
                            onReset: {
                                isShowingGameActions = false
                                resetAllScores()
                            },
                            onNewGame: {
                                isShowingGameActions = false
                                onNewGame()
                            },
                            onClose: {
                                withAnimation(controlsAnimation) {
                                    isShowingGameActions = false
                                }
                            }
                        )
                    } else {
                        HStack(spacing: 7) {
                            FinishGameButton {
                                finishGame()
                            }
                            .frame(maxWidth: 104)

                            MoreGameActionsButton {
                                withAnimation(controlsAnimation) {
                                    isShowingGameActions = true
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .animation(controlsAnimation, value: isShowingGameActions)
            } else {
                EmptyGameView(
                    onNewGame: {
                        onNewGame()
                    }
                )
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .focusable(true)
        .focused($isCrownFocused)
        .digitalCrownRotation(
            $crownValue,
            from: 0,
            through: maximumCrownValue,
            by: 1,
            sensitivity: .low,
            isContinuous: false,
            isHapticFeedbackEnabled: true
        )
        .onChange(of: crownValue) { _, newValue in
            updateSelectedPlayerFromCrownValue(newValue)
        }
        .onChange(of: isShowingGameActions) { _, isShowing in
            isCrownFocused = !isShowing
        }
        .onAppear {
            crownValue = Double(gameState.selectedPlayerIndex)

            DispatchQueue.main.async {
                isCrownFocused = true
            }
        }
        .onDisappear {
            isCrownFocused = false
        }
    }

    private func updateSelectedPlayerFromCrownValue(_ newValue: Double) {
        let newIndex = Int(newValue.rounded())

        guard gameState.players.indices.contains(newIndex),
              newIndex != gameState.selectedPlayerIndex
        else {
            return
        }

        withAnimation(selectionAnimation) {
            gameState.selectPlayer(at: newIndex)
        }

        // digitalCrownRotation already provides detent haptics.
    }

    private func incrementSelectedPlayerScore() {
        withAnimation(scoreAnimation) {
            gameState.incrementSelectedPlayerScore()
        }

        WKInterfaceDevice.current().play(.click)
    }

    private func decrementSelectedPlayerScore() {
        withAnimation(scoreAnimation) {
            gameState.decrementSelectedPlayerScore()
        }

        WKInterfaceDevice.current().play(.directionDown)
    }

    private func resetAllScores() {
        withAnimation(resetAnimation) {
            gameState.resetAllScores()
            crownValue = 0
        }

        WKInterfaceDevice.current().play(.directionDown)
    }

    private func finishGame() {
        WKInterfaceDevice.current().play(.success)
        onFinishGame()
    }

    private var selectionAnimation: Animation? {
        reduceMotion ? nil : .spring(response: 0.18, dampingFraction: 0.88)
    }

    private var scoreAnimation: Animation? {
        reduceMotion ? nil : .spring(response: 0.18, dampingFraction: 0.86)
    }

    private var resetAnimation: Animation? {
        reduceMotion ? nil : .easeInOut(duration: 0.16)
    }

    private var controlsAnimation: Animation? {
        reduceMotion ? nil : .easeInOut(duration: 0.14)
    }
}

private struct BottomControlsSlot<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            content
        }
        .frame(maxWidth: .infinity)
        .frame(height: 36)
        .clipped()
    }
}

private struct FinishGameButton: View {
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Text("Finish")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.white.opacity(0.92))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(Color.white.opacity(0.24), lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .accessibilityLabel("Finish game")
    }
}

private struct MoreGameActionsButton: View {
    let action: () -> Void

    var body: some View {
        Button {
            WKInterfaceDevice.current().play(.click)
            action()
        } label: {
            VStack(spacing: 1) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .semibold))

                Text("More")
                    .font(.system(size: 7, weight: .semibold))
                    .lineLimit(1)
            }
            .foregroundStyle(.white.opacity(0.9))
            .frame(width: 52, height: 36)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.white.opacity(0.09))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("More game actions")
    }
}

private struct GameActionsTray: View {
    let summaryText: String
    let onReset: () -> Void
    let onNewGame: () -> Void
    let onClose: () -> Void

    var body: some View {
        HStack(spacing: 5) {
            ShareLink(
                item: summaryText,
                preview: SharePreview("Archery 21 Scores")
            ) {
                GameActionTrayLabel(
                    title: "Share",
                    systemImage: "square.and.arrow.up",
                    color: Color(red: 0.56, green: 0.78, blue: 0.74)
                )
            }
            .buttonStyle(.plain)

            Button {
                onReset()
            } label: {
                GameActionTrayLabel(
                    title: "Reset",
                    systemImage: "arrow.counterclockwise",
                    color: .red.opacity(0.92)
                )
            }
            .buttonStyle(.plain)

            Button {
                onNewGame()
            } label: {
                GameActionTrayLabel(
                    title: "New",
                    systemImage: "plus",
                    color: .white.opacity(0.9)
                )
            }
            .buttonStyle(.plain)

            Button {
                onClose()
            } label: {
                GameActionTrayLabel(
                    title: "Back",
                    systemImage: "chevron.down",
                    color: .white.opacity(0.9)
                )
            }
            .buttonStyle(.plain)
        }
        .accessibilityElement(children: .contain)
    }
}

private struct GameActionTrayLabel: View {
    let title: String
    let systemImage: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: systemImage)
                .font(.system(size: 12, weight: .semibold))

            Text(title)
                .font(.system(size: 7, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .foregroundStyle(color)
        .frame(maxWidth: .infinity)
        .frame(height: 36)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.white.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(color.opacity(0.18), lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
