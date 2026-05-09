//
//  EmptyGameView.swift
//  BlackJack Archery
//
//  Created by Hunter Hartline on 5/7/26.
//

import SwiftUI

struct EmptyGameView: View {
    let onNewGame: () -> Void

    var body: some View {
        VStack(spacing: 7) {
            Text("No players")
                .font(.system(size: 15, weight: .semibold))

            Text("Start a new game.")
                .font(.system(size: 10, weight: .regular))
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button {
                onNewGame()
            } label: {
                EmptyGameActionLabel()
            }
            .buttonStyle(.plain)
        }
    }
}

private struct EmptyGameActionLabel: View {
    var body: some View {
        Text("New Game")
            .font(.system(size: 11, weight: .semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .foregroundStyle(.black)
            .frame(width: 86, height: 28)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.white.opacity(0.92))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.24), lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
