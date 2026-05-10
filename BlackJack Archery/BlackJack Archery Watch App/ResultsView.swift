//
//  ResultsView.swift
//  BlackJack Archery
//
//  Created by Hunter Hartline on 5/8/26.
//

import ImageIO
import SwiftUI
import UniformTypeIdentifiers

struct ResultsView: View {
    let result: GameResult
    let onNewGame: () -> Void

    private let rankedResults: [RankedPlayerResult]
    private let outcomeTitleText: String
    private let outcomeValueText: String
    private let hasWinner: Bool

    @State private var scorecardShareURL: URL?
    @State private var renderedScorecardResultID: UUID?
    @State private var isRevealed = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(
        result: GameResult,
        onNewGame: @escaping () -> Void
    ) {
        self.result = result
        self.onNewGame = onNewGame
        // The result is immutable on this screen, so cache derived header text and row order once.
        self.outcomeTitleText = result.outcomeTitle
        self.outcomeValueText = result.outcomeText
        self.hasWinner = result.hasWinner

        self.rankedResults = result.sortedPlayerResults
            .enumerated()
            .map { offset, playerResult in
                RankedPlayerResult(
                    rank: offset + 1,
                    playerResult: playerResult
                )
            }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 7) {
                header

                VStack(spacing: 4) {
                    ForEach(rankedResults) { rankedResult in
                        ResultRow(
                            rank: rankedResult.rank,
                            playerResult: rankedResult.playerResult
                        )
                            .equatable()
                            .opacity(isRevealed ? 1 : 0)
                            .offset(y: reduceMotion || isRevealed ? 0 : 8)
                            .animation(
                                rowRevealAnimation(for: rankedResult.index),
                                value: isRevealed
                            )
                    }
                }

                HStack(spacing: 6) {
                    shareButton

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
            prepareScorecardShareImage()

            withAnimation(revealAnimation) {
                isRevealed = true
            }
        }
        .onChange(of: result.id) { _, _ in
            isRevealed = false
            prepareScorecardShareImage()

            withAnimation(revealAnimation) {
                isRevealed = true
            }
        }
    }

    @ViewBuilder
    private var shareButton: some View {
        if let scorecardShareURL {
            ShareLink(
                item: scorecardShareURL,
                preview: SharePreview("Archery 21 Results")
            ) {
                shareButtonLabel
            }
            .buttonStyle(.plain)
        } else {
            Button {
            } label: {
                shareButtonLabel
            }
            .buttonStyle(.plain)
            .allowsHitTesting(false)
        }
    }

    private var shareButtonLabel: some View {
        ResultsActionLabel(
            title: "Share",
            systemImage: "square.and.arrow.up",
            isPrimary: true
        )
    }

    @MainActor
    private func prepareScorecardShareImage() {
        guard renderedScorecardResultID != result.id else {
            return
        }

        scorecardShareURL = nil

        guard let renderedURL = ScorecardShareRenderer.makeImageURL(for: result) else {
            renderedScorecardResultID = nil
            return
        }

        renderedScorecardResultID = result.id
        scorecardShareURL = renderedURL
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
                Text(outcomeTitleText)
                    .font(.system(size: 10, weight: .semibold))
                    .textCase(.uppercase)
                    .foregroundStyle(.secondary)

                Spacer(minLength: 4)

                Text(outcomeValueText)
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

    private var outcomeTextColor: Color {
        hasWinner
            ? Color(red: 0.55, green: 0.84, blue: 0.66)
            : .white.opacity(0.92)
    }
}

private struct RankedPlayerResult: Identifiable, Equatable {
    let rank: Int
    let playerResult: PlayerResult

    var id: UUID {
        playerResult.id
    }

    var index: Int {
        rank - 1
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

private enum ScorecardShareRenderer {
    private static let imageSize = CGSize(width: 320, height: 220)

    @MainActor
    static func makeImageURL(for result: GameResult) -> URL? {
        let content = ScorecardShareImageView(result: result)
            .frame(width: imageSize.width, height: imageSize.height)
            .environment(\.colorScheme, .dark)

        let renderer = ImageRenderer(content: content)
        renderer.scale = 2

        guard let cgImage = renderer.cgImage else {
            return nil
        }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("archery-21-\(result.id.uuidString)")
            .appendingPathExtension("png")

        try? FileManager.default.removeItem(at: url)

        guard let destination = CGImageDestinationCreateWithURL(
            url as CFURL,
            UTType.png.identifier as CFString,
            1,
            nil
        ) else {
            return nil
        }

        CGImageDestinationAddImage(destination, cgImage, nil)

        guard CGImageDestinationFinalize(destination) else {
            return nil
        }

        return url
    }
}

private struct ScorecardShareImageView: View {
    let result: GameResult
    private let sortedResults: [PlayerResult]

    init(result: GameResult) {
        let sortedResults = result.sortedPlayerResults

        self.result = result
        self.sortedResults = sortedResults
    }

    private var scorecardColumns: [GridItem] {
        let columnCount = sortedResults.count > 4 ? 2 : 1

        return Array(
            repeating: GridItem(.flexible(), spacing: 6),
            count: columnCount
        )
    }

    var body: some View {
        ZStack {
            Color.black

            VStack(spacing: 6) {
                HStack(spacing: 8) {
                    Text("Scores 🎯")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.96))
                        .lineLimit(1)

                    Spacer(minLength: 8)

                    Text("\(result.targetScore) target")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 10)
                        .frame(height: 24)
                        .background(
                            Capsule()
                                .fill(Color.yellow.opacity(0.94))
                        )
                }

                if sortedResults.isEmpty {
                    Text("No scores recorded.")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.84))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.white.opacity(0.06))
                        )
                } else {
                    LazyVGrid(columns: scorecardColumns, spacing: 6) {
                        ForEach(Array(sortedResults.enumerated()), id: \.element.id) { index, playerResult in
                            ScorecardShareResultRow(
                                rank: index + 1,
                                playerResult: playerResult,
                                accentColor: scoreColor(for: playerResult.status),
                                isCompact: sortedResults.count > 4
                            )
                        }
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.075))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
            )
            .padding(10)
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
}

private struct ScorecardShareResultRow: View {
    let rank: Int
    let playerResult: PlayerResult
    let accentColor: Color
    let isCompact: Bool

    var body: some View {
        HStack(spacing: 5) {
            Text("\(rank)")
                .font(.system(size: isCompact ? 11 : 12, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(.black)
                .frame(
                    width: isCompact ? 20 : 22,
                    height: isCompact ? 20 : 22
                )
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(accentColor)
                )

            Text(playerResult.initials)
                .font(.system(size: isCompact ? 15 : 16, weight: .semibold))
                .monospaced()
                .foregroundStyle(.white.opacity(0.94))
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Spacer(minLength: 4)

            Text("\(playerResult.finalScore)")
                .font(.system(size: isCompact ? 18 : 20, weight: .semibold))
                .monospacedDigit()
                .foregroundStyle(accentColor)
                .lineLimit(1)
        }
        .padding(.horizontal, 7)
        .frame(height: isCompact ? 30 : 32)
        .background(
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(rowBackgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .strokeBorder(accentColor.opacity(0.26), lineWidth: 1)
        )
    }

    private var rowBackgroundColor: Color {
        switch playerResult.status {
        case .playing:
            return Color.white.opacity(0.06)
        case .exact:
            return Color.yellow.opacity(0.12)
        case .bust:
            return Color.red.opacity(0.11)
        }
    }
}
