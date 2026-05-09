//
//  ResultsView.swift
//  BlackJack Archery
//
//  Created by Hunter Hartline on 5/8/26.
//

import SwiftUI

struct ResultsView: View {
    let result: GameResult
    let onNewGame: () -> Void

    @State private var isRevealed = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ScrollView {
            VStack(spacing: 7) {
                header

                VStack(spacing: 4) {
                    ForEach(
                        Array(sortedResults.enumerated()),
                        id: \.element.id
                    ) { index, playerResult in
                        ResultRow(rank: index + 1, playerResult: playerResult)
                            .opacity(isRevealed ? 1 : 0)
                            .offset(y: reduceMotion || isRevealed ? 0 : 8)
                            .animation(
                                rowRevealAnimation(for: index),
                                value: isRevealed
                            )
                    }
                }

                HStack(spacing: 6) {
                    ShareLink(
                        item: result.summaryText,
                        preview: SharePreview("Archery 21 Results")
                    ) {
                        ResultsActionLabel(
                            title: "Share",
                            systemImage: "square.and.arrow.up",
                            isPrimary: true
                        )
                    }
                    .buttonStyle(.plain)

                    Button {
                        onNewGame()
                    } label: {
                        ResultsActionLabel(
                            title: "New",
                            systemImage: "plus",
                            isPrimary: false
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
        }
        .onAppear {
            isRevealed = false

            withAnimation(revealAnimation) {
                isRevealed = true
            }
        }
        .onChange(of: result.id) { _, _ in
            isRevealed = false

            withAnimation(revealAnimation) {
                isRevealed = true
            }
        }
    }

    private var revealAnimation: Animation? {
        reduceMotion ? nil : .easeOut(duration: 0.16)
    }

    private func rowRevealAnimation(for index: Int) -> Animation? {
        if reduceMotion {
            return nil
        }

        return .easeOut(duration: 0.22)
            .delay(Double(index) * 0.035)
    }

    private var header: some View {
        VStack(spacing: 5) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 1) {
                    Text("Results")
                        .font(.system(size: 15, weight: .semibold))

                    Text("\(result.playerResults.count) players")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 8)

                Text("\(result.targetScore)")
                    .font(.system(size: 14, weight: .semibold))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.07))
                    )
                    .overlay(
                        Capsule()
                            .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .accessibilityLabel("Target \(result.targetScore)")
            }

            HStack(spacing: 6) {
                Text(result.outcomeTitle)
                    .font(.system(size: 10, weight: .semibold))
                    .textCase(.uppercase)
                    .foregroundStyle(.secondary)

                Spacer(minLength: 4)

                Text(result.outcomeText)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(outcomeTextColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)
                    .multilineTextAlignment(.trailing)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.white.opacity(0.07))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
    }

    private var sortedResults: [PlayerResult] {
        result.sortedPlayerResults
    }

    private var outcomeTextColor: Color {
        result.hasWinner
            ? Color(red: 0.55, green: 0.84, blue: 0.66)
            : .white.opacity(0.92)
    }
}

private struct ResultsActionLabel: View {
    let title: String
    let systemImage: String
    let isPrimary: Bool

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.system(size: 11, weight: .semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.82)
            .foregroundStyle(isPrimary ? .black : .white.opacity(0.9))
            .frame(maxWidth: .infinity)
            .frame(height: 28)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(isPrimary ? Color.white.opacity(0.92) : Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(Color.white.opacity(isPrimary ? 0.24 : 0.12), lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
