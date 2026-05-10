//
//  RulesView.swift
//  BlackJack Archery
//
//  Created by Hunter Hartline on 5/9/26.
//

import SwiftUI

struct RulesView: View {
    let onDone: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 7) {
                header

                RuleCallout(
                    title: "Goal",
                    text: "Get to 21 without going over."
                )

                VStack(alignment: .leading, spacing: 5) {
                    RuleLine(text: "Exact 21 wins.")
                    RuleLine(text: "Over 21 is bust.")
                    RuleLine(text: "No 21: closest under wins.")
                    RuleLine(text: "All bust: replay by house rule.")
                }

                RuleCallout(
                    title: "Cards",
                    text: "Card target: numbers face value, J/Q/K = 10, Ace = 1 or 11."
                )

                Button {
                    onDone()
                } label: {
                    Text("Done")
                        .font(.system(size: 12, weight: .semibold))
                        .lineLimit(1)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 30)
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
                .buttonStyle(.plain)
            }
            .padding(.vertical, 2)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text("Rules")
                .font(.system(size: 15, weight: .semibold))

            Text("Blackjack Archery 21")
                .font(.system(size: 10, weight: .regular))
                .foregroundStyle(.secondary)
        }
    }
}

private struct RuleCallout: View {
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 9, weight: .semibold))
                .textCase(.uppercase)
                .foregroundStyle(Color(red: 0.56, green: 0.78, blue: 0.74))

            Text(text)
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(.white.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 7)
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

private struct RuleLine: View {
    let text: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 5) {
            Circle()
                .fill(Color(red: 0.56, green: 0.78, blue: 0.74))
                .frame(width: 4, height: 4)

            Text(text)
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(.white.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
