//
//  StatusBadge.swift
//  BlackJack Archery
//
//  Created by Hunter Hartline on 5/7/26.
//

import SwiftUI

struct StatusBadge: View {
    let status: PlayerStatus

    var body: some View {
        Text(statusLabel)
            .font(.system(size: 10, weight: .semibold))
            .textCase(.uppercase)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(backgroundColor)
            )
            .overlay(
                Capsule()
                    .strokeBorder(borderColor, lineWidth: 1)
            )
            .foregroundStyle(foregroundColor)
    }

    private var statusLabel: String {
        switch status {
        case .playing:
            return "Live"
        case .exact:
            return "21"
        case .bust:
            return "Bust"
        }
    }

    private var backgroundColor: Color {
        switch status {
        case .playing:
            return .white.opacity(0.08)
        case .exact:
            return .yellow.opacity(0.18)
        case .bust:
            return .red.opacity(0.18)
        }
    }

    private var foregroundColor: Color {
        switch status {
        case .playing:
            return .white.opacity(0.74)
        case .exact:
            return .yellow
        case .bust:
            return .red
        }
    }

    private var borderColor: Color {
        switch status {
        case .playing:
            return .white.opacity(0.12)
        case .exact:
            return .yellow.opacity(0.32)
        case .bust:
            return .red.opacity(0.32)
        }
    }
}
