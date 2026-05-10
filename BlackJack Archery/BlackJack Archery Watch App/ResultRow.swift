//
//  ResultRow.swift
//  BlackJack Archery
//
//  Created by Hunter Hartline on 5/8/26.
//

import SwiftUI

struct ResultRow: View, Equatable {
    let rank: Int
    let playerResult: PlayerResult

    var body: some View {
        HStack(spacing: 7) {
            Text("\(rank)")
                .font(.system(size: 11, weight: .semibold))
                .monospacedDigit()
                .foregroundStyle(.secondary)
                .frame(width: 14, alignment: .leading)

            Text(playerResult.initials)
                .font(.system(size: 14, weight: .semibold))
                .monospaced()
                .lineLimit(1)

            if let statusLabel {
                Text(statusLabel)
                    .font(.system(size: 9, weight: .semibold))
                    .textCase(.uppercase)
                    .foregroundStyle(statusColor)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(statusColor.opacity(0.14))
                    )
                    .overlay(
                        Capsule()
                            .strokeBorder(statusColor.opacity(0.22), lineWidth: 1)
                    )
            }

            Spacer(minLength: 4)

            Text("\(playerResult.finalScore)")
                .font(.system(size: 15, weight: .semibold))
                .monospacedDigit()
                .foregroundStyle(statusColor)
                .contentTransition(.numericText())
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(backgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(borderColor, lineWidth: 1)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    private var statusLabel: String? {
        switch playerResult.status {
        case .playing:
            return nil
        case .exact:
            return "Win"
        case .bust:
            return "Bust"
        }
    }

    private var statusColor: Color {
        switch playerResult.status {
        case .playing:
            return .white.opacity(0.92)
        case .exact:
            return .yellow
        case .bust:
            return .red
        }
    }

    private var backgroundColor: Color {
        switch playerResult.status {
        case .playing:
            return .white.opacity(0.06)
        case .exact:
            return .yellow.opacity(0.1)
        case .bust:
            return .red.opacity(0.09)
        }
    }

    private var borderColor: Color {
        switch playerResult.status {
        case .playing:
            return .white.opacity(0.08)
        case .exact:
            return .yellow.opacity(0.26)
        case .bust:
            return .red.opacity(0.24)
        }
    }

    private var accessibilityLabel: String {
        let statusText = statusLabel.map { ", \($0)" } ?? ""
        return "Rank \(rank), \(playerResult.initials), \(playerResult.finalScore)\(statusText)"
    }
}
