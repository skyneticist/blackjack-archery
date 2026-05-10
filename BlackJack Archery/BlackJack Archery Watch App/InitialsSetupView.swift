//
//  InitialsSetupView.swift
//  BlackJack Archery
//
//  Created by Hunter Hartline on 5/7/26.
//

import SwiftUI
import WatchKit

struct InitialsSetupView: View {
    @Binding var drafts: [InitialsDraft]

    let onBack: () -> Void
    let onStart: () -> Void

    private static let allowedCharacters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789").map(String.init)
    private static let allowedCharacterIndexes = Dictionary(
        uniqueKeysWithValues: allowedCharacters.enumerated().map { index, character in
            (character, index)
        }
    )

    @State private var currentPlayerIndex: Int = 0
    @State private var selectedCharacterSlot: Int = 0
    @State private var crownValue: Double = 0

    @FocusState private var isCrownFocused: Bool

    private var currentDraft: InitialsDraft? {
        guard drafts.indices.contains(currentPlayerIndex) else {
            return nil
        }

        return drafts[currentPlayerIndex]
    }

    private var currentCharacterIndex: Int {
        let currentCharacter = currentDraft?.characters[selectedCharacterSlot] ?? "A"

        return Self.allowedCharacterIndexes[currentCharacter] ?? 0
    }

    private var maximumCharacterIndex: Double {
        Double(max(Self.allowedCharacters.count - 1, 0))
    }

    var body: some View {
        VStack(spacing: 6) {
            Text("Initials")
                .font(.system(size: 15, weight: .semibold))

            if let draft = currentDraft {
                Text("Player \(currentPlayerIndex + 1) of \(drafts.count)")
                    .font(.system(size: 10, weight: .regular))
                    .foregroundStyle(.secondary)

                initialsDisplay(for: draft)

                InitialsActionButton(
                    title: "Next",
                    width: 58,
                    isPrimary: false
                ) {
                    moveToNextCharacterSlot()
                }

                HStack(spacing: 6) {
                    InitialsActionButton(
                        title: "Back",
                        width: 52,
                        isPrimary: false
                    ) {
                        goBack()
                    }

                    InitialsActionButton(
                        title: nextPlayerButtonTitle,
                        width: 86,
                        isPrimary: true
                    ) {
                        moveToNextPlayerOrStart()
                    }
                }
            } else {
                Text("No players")
                    .foregroundStyle(.secondary)

                Button("Back") {
                    onBack()
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .focusable(true)
        .focused($isCrownFocused)
        .digitalCrownRotation(
            $crownValue,
            from: 0,
            through: maximumCharacterIndex,
            by: 1,
            sensitivity: .medium,
            isContinuous: false,
            isHapticFeedbackEnabled: true
        )
        .onChange(of: crownValue) { _, newValue in
            updateSelectedCharacterFromCrownValue(newValue)
        }
        .onAppear {
            syncCrownValueToSelectedCharacter()

            DispatchQueue.main.async {
                isCrownFocused = true
            }
        }
        .onDisappear {
            isCrownFocused = false
        }
    }

    private var nextPlayerButtonTitle: String {
        currentPlayerIndex == drafts.count - 1 ? "Start" : "Next Player"
    }

    private func initialsDisplay(for draft: InitialsDraft) -> some View {
        HStack(spacing: 6) {
            ForEach(draft.characters.indices, id: \.self) { index in
                VStack(spacing: 3) {
                    Text(draft.characters[index])
                        .font(.system(size: 26, weight: .semibold))
                        .monospaced()
                        .frame(width: 32, height: 34)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(index == selectedCharacterSlot ? Color.yellow.opacity(0.2) : Color.white.opacity(0.08))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .strokeBorder(index == selectedCharacterSlot ? Color.yellow.opacity(0.55) : Color.white.opacity(0.1), lineWidth: 1)
                        )

                    Circle()
                        .frame(width: 4, height: 4)
                        .opacity(index == selectedCharacterSlot ? 1.0 : 0.0)
                }
            }
        }
    }

    private func updateSelectedCharacterFromCrownValue(_ newValue: Double) {
        guard drafts.indices.contains(currentPlayerIndex),
              drafts[currentPlayerIndex].characters.indices.contains(selectedCharacterSlot)
        else {
            return
        }

        let newCharacterIndex = Int(newValue.rounded())

        guard Self.allowedCharacters.indices.contains(newCharacterIndex) else {
            return
        }

        let newCharacter = Self.allowedCharacters[newCharacterIndex]

        guard drafts[currentPlayerIndex].characters[selectedCharacterSlot] != newCharacter else {
            return
        }

        drafts[currentPlayerIndex].setCharacter(newCharacter, at: selectedCharacterSlot)

        // digitalCrownRotation already provides detent haptics.
    }

    private func moveToNextCharacterSlot() {
        guard let draft = currentDraft else {
            return
        }

        withAnimation(.spring(response: 0.18, dampingFraction: 0.86)) {
            selectedCharacterSlot = (selectedCharacterSlot + 1) % draft.characters.count
            syncCrownValueToSelectedCharacter()
        }

        WKInterfaceDevice.current().play(.click)
    }

    private func moveToNextPlayerOrStart() {
        if currentPlayerIndex == drafts.count - 1 {
            onStart()
            return
        }

        withAnimation(.spring(response: 0.18, dampingFraction: 0.88)) {
            currentPlayerIndex += 1
            selectedCharacterSlot = 0
            syncCrownValueToSelectedCharacter()
        }

        WKInterfaceDevice.current().play(.success)
    }

    private func goBack() {
        if currentPlayerIndex > 0 {
            withAnimation(.spring(response: 0.18, dampingFraction: 0.88)) {
                currentPlayerIndex -= 1
                selectedCharacterSlot = 0
                syncCrownValueToSelectedCharacter()
            }

            WKInterfaceDevice.current().play(.directionDown)
        } else {
            onBack()
        }
    }

    private func syncCrownValueToSelectedCharacter() {
        crownValue = Double(currentCharacterIndex)
    }
}

private struct InitialsActionButton: View {
    let title: String
    let width: CGFloat
    let isPrimary: Bool
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .foregroundStyle(isPrimary ? .black : .white.opacity(0.88))
                .frame(width: width, height: 25)
        }
        .buttonStyle(.plain)
        .background(background)
        .overlay(border)
        .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var background: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(isPrimary ? Color.white.opacity(0.92) : Color.white.opacity(0.09))
    }

    private var border: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .strokeBorder(Color.white.opacity(isPrimary ? 0.24 : 0.12), lineWidth: 1)
    }
}
