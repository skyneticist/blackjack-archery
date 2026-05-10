//
//  InitialsDraft.swift
//  BlackJack Archery
//
//  Created by Hunter Hartline on 5/7/26.
//

import Foundation

struct InitialsDraft: Identifiable, Equatable {
    let id: UUID
    var characters: [String]

    init(
        id: UUID = UUID(),
        characters: [String] = ["A", "A", "A"]
    ) {
        self.id = id
        self.characters = characters
    }

    var initials: String {
        characters.joined()
    }

    mutating func setCharacter(_ character: String, at index: Int) {
        guard characters.indices.contains(index) else {
            return
        }

        characters[index] = character
    }
}
