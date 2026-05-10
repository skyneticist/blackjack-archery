//
//  PlayerScore.swift
//  BlackJack Archery
//
//  Created by Hunter Hartline on 5/6/26.
//

import Foundation

struct PlayerScore: Equatable {
    var score: Int = 0

    let targetScore: Int = 21

    var status: PlayerStatus {
        if score == targetScore {
            return .exact
        } else if score > targetScore {
            return .bust
        } else {
            return .playing
        }
    }

    mutating func increment() {
        score += 1
    }

    mutating func decrement() {
        score = max(0, score - 1)
    }

    mutating func reset() {
        score = 0
    }
}
