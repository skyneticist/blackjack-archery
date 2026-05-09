//
//  GameResult.swift
//  BlackJack Archery
//
//  Created by Hunter Hartline on 5/8/26.
//

import Foundation

struct GameResult: Identifiable, Equatable {
    let id: UUID
    let finishedAt: Date
    let targetScore: Int
    let playerResults: [PlayerResult]

    init(
        id: UUID = UUID(),
        finishedAt: Date = Date(),
        targetScore: Int = Player.targetScore,
        playerResults: [PlayerResult]
    ) {
        self.id = id
        self.finishedAt = finishedAt
        self.targetScore = targetScore
        self.playerResults = playerResults
    }

    var winners: [PlayerResult] {
        playerResults.filter { $0.didWin }
    }

    var hasWinner: Bool {
        !winners.isEmpty
    }

    var leadingNonBustResults: [PlayerResult] {
        let eligibleResults = playerResults.filter { !$0.didBust }
        let topScore = eligibleResults.map(\.finalScore).max()

        guard let topScore else {
            return []
        }

        return eligibleResults.filter { $0.finalScore == topScore }
    }

    var winnerText: String {
        if winners.isEmpty {
            return "No winner"
        }

        return winners
            .map { $0.initials }
            .joined(separator: ", ")
    }

    var outcomeTitle: String {
        if hasWinner {
            return winners.count == 1 ? "Winner" : "Winners"
        }

        return leadingNonBustResults.isEmpty ? "Outcome" : "Closest"
    }

    var outcomeText: String {
        if hasWinner {
            return winnerText
        }

        if leadingNonBustResults.isEmpty {
            return "All bust"
        }

        return leadingNonBustResults
            .map { "\($0.initials) \($0.finalScore)" }
            .joined(separator: ", ")
    }

    var sortedPlayerResults: [PlayerResult] {
        playerResults.sorted { first, second in
            if first.didWin && !second.didWin {
                return true
            }

            if !first.didWin && second.didWin {
                return false
            }

            if first.didBust && !second.didBust {
                return false
            }

            if !first.didBust && second.didBust {
                return true
            }

            return first.finalScore > second.finalScore
        }
    }

    var summaryText: String {
        let sortedResults = sortedPlayerResults
        let leadingResultIDs = Set(leadingNonBustResults.map(\.id))
        let playerWidth = max(3, sortedResults.map(\.initials.count).max() ?? 0)
        let scoreWidth = max(2, sortedResults.map { String($0.finalScore).count }.max() ?? 0)
        var lines: [String] = []

        lines.append("Archery 21")
        lines.append("")
        lines.append(shareOutcomeTitle)
        lines.append(shareOutcomeDetail)
        lines.append("")
        lines.append("Target: \(targetScore)")
        lines.append("Players: \(playerResults.count)")
        lines.append("")
        lines.append("Scorecard")

        if sortedResults.isEmpty {
            lines.append("No scores recorded.")
        } else {
            for (index, result) in sortedResults.enumerated() {
                let rankText = leftPadded(
                    "\(index + 1)",
                    to: String(sortedResults.count).count
                )
                let scoreText = leftPadded(
                    "\(result.finalScore)",
                    to: scoreWidth
                )
                let statusText = shareStatus(
                    for: result,
                    leadingResultIDs: leadingResultIDs
                )
                let statusSuffix = statusText.map { "   \($0)" } ?? ""

                lines.append("\(rankText). \(padded(result.initials, to: playerWidth))   \(scoreText)\(statusSuffix)")
            }
        }

        return lines.joined(separator: "\n")
    }

    private var shareOutcomeTitle: String {
        if hasWinner {
            return winners.count == 1 ? "Winner" : "Winners"
        }

        return leadingNonBustResults.isEmpty ? "No winner" : "Closest"
    }

    private var shareOutcomeDetail: String {
        if hasWinner {
            let subject = listText(winners.map(\.initials))
            let verb = winners.count == 1 ? "wins" : "win"

            return "\(subject) \(verb) with \(targetScore)"
        }

        if leadingNonBustResults.isEmpty {
            return "All players bust"
        }

        let closestText = leadingNonBustResults
            .map { "\($0.initials) \($0.finalScore)" }

        return listText(closestText)
    }

    private func shareStatus(
        for result: PlayerResult,
        leadingResultIDs: Set<UUID>
    ) -> String? {
        if result.didWin {
            return "WIN"
        }

        if result.didBust {
            return "BUST"
        }

        if !hasWinner && leadingResultIDs.contains(result.id) {
            return "CLOSE"
        }

        return nil
    }

    private func padded(_ value: String, to length: Int) -> String {
        if value.count >= length {
            return value
        }

        return value.padding(
            toLength: length,
            withPad: " ",
            startingAt: 0
        )
    }

    private func leftPadded(_ value: String, to length: Int) -> String {
        if value.count >= length {
            return value
        }

        return String(repeating: " ", count: length - value.count) + value
    }

    private func listText(_ values: [String]) -> String {
        switch values.count {
        case 0:
            return ""
        case 1:
            return values[0]
        case 2:
            return "\(values[0]) and \(values[1])"
        default:
            let leadingValues = values.dropLast().joined(separator: ", ")
            return "\(leadingValues), and \(values[values.count - 1])"
        }
    }
}
