//
//  PlayerResult.swift
//  BlackJack Archery
//
//  Created by Hunter Hartline on 5/8/26.
//

import Foundation

struct PlayerResult: Identifiable, Equatable {
    let id: UUID
    let initials: String
    let finalScore: Int
    let status: PlayerStatus

    init(player: Player) {
        self.id = player.id
        self.initials = player.initials
        self.finalScore = player.score
        self.status = player.status
    }

    var didWin: Bool {
        status == .exact
    }

    var didBust: Bool {
        status == .bust
    }

    var displayScore: String {
        if didBust {
            return "BUST \(finalScore)"
        } else {
            return "\(finalScore)"
        }
    }
}
