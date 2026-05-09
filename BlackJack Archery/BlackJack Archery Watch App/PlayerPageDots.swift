//
//  PlayerPageDots.swift
//  BlackJack Archery
//
//  Created by Hunter Hartline on 5/7/26.
//

import SwiftUI

struct PlayerPageDots: View {
    let count: Int
    let selectedIndex: Int

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .frame(
                        width: index == selectedIndex ? 12 : 4,
                        height: 4
                    )
                    .opacity(index == selectedIndex ? 1.0 : 0.35)
            }
        }
        .animation(.easeOut(duration: 0.16), value: selectedIndex)
    }
}
