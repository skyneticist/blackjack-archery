//
//  Player.swift
//  BlackJack Archery
//
//  Created by Hunter Hartline on 5/6/26.
//

import Foundation

struct Player: Identifiable, Equatable {
    var id: UUID
    var initials: String
    var score: Int

    static let targetScore: Int = 21

    init(initials: String) {
        self.id = UUID()
        self.initials = initials
        self.score = 0
    }

    var status: PlayerStatus {
        if score == Self.targetScore {
            return .exact
        } else if score > Self.targetScore {
            return .bust
        } else {
            return .playing
        }
    }

    mutating func incrementScore() {
        score += 1
    }

    mutating func decrementScore() {
        score = max(0, score - 1)
    }

    mutating func resetScore() {
        score = 0
    }
}
