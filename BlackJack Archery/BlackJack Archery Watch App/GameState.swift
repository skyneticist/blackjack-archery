//
//  GameState.swift
//  BlackJack Archery
//
//  Created by Hunter Hartline on 5/7/26.
//

import Foundation

struct GameState: Equatable {
    var players: [Player]
    var selectedPlayerIndex: Int

    init(
        players: [Player],
        selectedPlayerIndex: Int = 0
    ) {
        self.players = players
        self.selectedPlayerIndex = selectedPlayerIndex
        clampSelectedPlayerIndex()
    }

    var selectedPlayer: Player? {
        guard players.indices.contains(selectedPlayerIndex) else {
            return nil
        }

        return players[selectedPlayerIndex]
    }

    var selectedPlayerPositionText: String {
        guard !players.isEmpty else {
            return "No players"
        }

        return "Player \(selectedPlayerIndex + 1) of \(players.count)"
    }

    mutating func incrementSelectedPlayerScore() {
        guard players.indices.contains(selectedPlayerIndex) else {
            return
        }

        players[selectedPlayerIndex].incrementScore()
    }

    mutating func decrementSelectedPlayerScore() {
        guard players.indices.contains(selectedPlayerIndex) else {
            return
        }

        players[selectedPlayerIndex].decrementScore()
    }

    mutating func selectNextPlayer() {
        guard !players.isEmpty else {
            selectedPlayerIndex = 0
            return
        }

        selectedPlayerIndex = (selectedPlayerIndex + 1) % players.count
    }

    mutating func selectPreviousPlayer() {
        guard !players.isEmpty else {
            selectedPlayerIndex = 0
            return
        }

        selectedPlayerIndex =
            selectedPlayerIndex == 0
            ? players.count - 1
            : selectedPlayerIndex - 1
    }

    mutating func selectPlayer(at index: Int) {
        guard players.indices.contains(index) else {
            return
        }

        selectedPlayerIndex = index
    }

    mutating func resetAllScores() {
        for index in players.indices {
            players[index].resetScore()
        }

        selectedPlayerIndex = 0
    }

    func makeResult() -> GameResult {
        let results = players.map { player in
            PlayerResult(player: player)
        }

        return GameResult(playerResults: results)
    }

    mutating func clampSelectedPlayerIndex() {
        if players.isEmpty {
            selectedPlayerIndex = 0
        } else if selectedPlayerIndex < 0 {
            selectedPlayerIndex = 0
        } else if selectedPlayerIndex >= players.count {
            selectedPlayerIndex = players.count - 1
        }
    }
}
