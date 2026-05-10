import SwiftUI

struct GameHistoryView: View {
    let results: [GameResult]
    let onSelect: (GameResult) -> Void
    let onBack: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 7) {
                header

                if results.isEmpty {
                    emptyState
                } else {
                    VStack(spacing: 5) {
                        ForEach(results) { result in
                            Button {
                                onSelect(result)
                            } label: {
                                GameHistoryRow(result: result)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
        }
    }

    private var header: some View {
        HStack(spacing: 8) {
            Text("History")
                .font(.system(size: 15, weight: .semibold))

            Spacer(minLength: 6)

            Button {
                onBack()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
                    .frame(width: 30, height: 28)
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
            .buttonStyle(.plain)
            .accessibilityLabel("Back")
        }
    }

    private var emptyState: some View {
        Text("No games yet")
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.white.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
            )
    }
}

private struct GameHistoryRow: View {
    let result: GameResult

    var body: some View {
        HStack(spacing: 7) {
            VStack(alignment: .leading, spacing: 2) {
                Text(result.finishedAt, format: .dateTime.month(.abbreviated).day())
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.94))
                    .lineLimit(1)

                Text(result.finishedAt, format: .dateTime.hour().minute())
                    .font(.system(size: 9, weight: .regular))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 4)

            Text(winnerChipText)
                .font(.system(size: 10, weight: .semibold))
                .monospaced()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .foregroundStyle(historyMint)
                .padding(.horizontal, 7)
                .frame(height: 22)
                .frame(maxWidth: 78)
                .background(
                    Capsule()
                        .fill(historyMint.opacity(0.14))
                )
                .overlay(
                    Capsule()
                        .strokeBorder(historyMint.opacity(0.24), lineWidth: 1)
                )
        }
        .padding(.horizontal, 8)
        .frame(height: 42)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.white.opacity(0.065))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(Color.white.opacity(0.09), lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    private var winnerChipText: String {
        result.hasWinner ? result.winnerText : "No winner"
    }

    private var historyMint: Color {
        Color(red: 0.55, green: 0.84, blue: 0.66)
    }

    private var accessibilityLabel: String {
        "\(result.finishedAt.formatted(date: .abbreviated, time: .shortened)), \(winnerChipText)"
    }
}
