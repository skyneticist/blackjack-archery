//
//  PlayerStatus.swift
//  BlackJack Archery
//
//  Created by Hunter Hartline on 5/6/26.
//

import SwiftUI

enum PlayerStatus: Equatable {
    case playing
    case exact
    case bust

    var text: String {
        switch self {
        case .playing:
            return "Playing"
        case .exact:
            return "21"
        case .bust:
            return "BUST"
        }
    }

    var color: Color {
        switch self {
        case .playing:
            return .secondary
        case .exact:
            return .yellow
        case .bust:
            return .red
        }
    }
}
