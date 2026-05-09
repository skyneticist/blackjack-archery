//
//  ScoreButton.swift
//  BlackJack Archery
//
//  Created by Hunter Hartline on 5/7/26.
//

import SwiftUI

struct ScoreButton: View {
    let systemName: String
    let action: () -> Void
    let isPrimary: Bool

    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: systemName)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(iconColor)
                .frame(width: 34, height: 34)
                .background(
                    Circle()
                        .fill(backgroundColor)
                )
                .overlay(
                    Circle()
                        .strokeBorder(borderColor, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .contentShape(Circle())
        .accessibilityLabel(isPrimary ? "Add point" : "Subtract point")
    }

    private var iconColor: Color {
        isPrimary ? .black : .white.opacity(0.92)
    }

    private var backgroundColor: Color {
        isPrimary ? .white.opacity(0.92) : .white.opacity(0.1)
    }

    private var borderColor: Color {
        isPrimary ? .white.opacity(0.35) : .white.opacity(0.16)
    }
}
