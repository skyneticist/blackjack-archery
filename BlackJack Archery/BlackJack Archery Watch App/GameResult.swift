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

    private let winnersCache: [PlayerResult]
    private let leadingNonBustResultsCache: [PlayerResult]
    private let sortedPlayerResultsCache: [PlayerResult]

    init(
        id: UUID = UUID(),
        finishedAt: Date = Date(),
        targetScore: Int = Player.targetScore,
        playerResults: [PlayerResult]
    ) {
        let winners = playerResults.filter { $0.didWin }
        let leadingNonBustResults = Self.makeLeadingNonBustResults(from: playerResults)
        let sortedPlayerResults = Self.makeSortedPlayerResults(from: playerResults)

        self.id = id
        self.finishedAt = finishedAt
        self.targetScore = targetScore
        self.playerResults = playerResults
        self.winnersCache = winners
        self.leadingNonBustResultsCache = leadingNonBustResults
        self.sortedPlayerResultsCache = sortedPlayerResults
    }

    var winners: [PlayerResult] {
        winnersCache
    }

    var hasWinner: Bool {
        !winners.isEmpty
    }

    var leadingNonBustResults: [PlayerResult] {
        leadingNonBustResultsCache
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
        sortedPlayerResultsCache
    }

    var summaryText: String {
        let sortedResults = sortedPlayerResults
        let winningResults = sortedResults.filter { $0.didWin }
        let leadingResults = leadingNonBustResults
        let hasWinningResult = !winningResults.isEmpty
        let leadingResultIDs = Set(leadingResults.map(\.id))
        var playerWidth = 3
        var scoreWidth = 2
        let rankWidth = String(sortedResults.count).count
        var lines: [String] = []

        for result in sortedResults {
            playerWidth = max(playerWidth, result.initials.count)
            scoreWidth = max(scoreWidth, String(result.finalScore).count)
        }

        lines.reserveCapacity(8 + sortedResults.count)
        lines.append("Archery 21")
        lines.append("")
        lines.append(
            shareOutcomeTitle(
                winningResults: winningResults,
                leadingResults: leadingResults
            )
        )
        lines.append(
            shareOutcomeDetail(
                winningResults: winningResults,
                leadingResults: leadingResults
            )
        )
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
                    to: rankWidth
                )
                let scoreText = leftPadded(
                    "\(result.finalScore)",
                    to: scoreWidth
                )
                let statusText = shareStatus(
                    for: result,
                    hasWinningResult: hasWinningResult,
                    leadingResultIDs: leadingResultIDs
                )
                let statusSuffix = statusText.map { "   \($0)" } ?? ""

                lines.append("\(rankText). \(padded(result.initials, to: playerWidth))   \(scoreText)\(statusSuffix)")
            }
        }

        return lines.joined(separator: "\n")
    }

    private static func makeLeadingNonBustResults(from playerResults: [PlayerResult]) -> [PlayerResult] {
        var topScore: Int?
        var leadingResults: [PlayerResult] = []

        for result in playerResults where !result.didBust {
            if let currentTopScore = topScore {
                if result.finalScore > currentTopScore {
                    topScore = result.finalScore
                    leadingResults = [result]
                } else if result.finalScore == currentTopScore {
                    leadingResults.append(result)
                }
            } else {
                topScore = result.finalScore
                leadingResults = [result]
            }
        }

        return leadingResults
    }

    private static func makeSortedPlayerResults(from playerResults: [PlayerResult]) -> [PlayerResult] {
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

    private func shareOutcomeTitle(
        winningResults: [PlayerResult],
        leadingResults: [PlayerResult]
    ) -> String {
        if !winningResults.isEmpty {
            return winningResults.count == 1 ? "Winner" : "Winners"
        }

        return leadingResults.isEmpty ? "No winner" : "Closest"
    }

    private func shareOutcomeDetail(
        winningResults: [PlayerResult],
        leadingResults: [PlayerResult]
    ) -> String {
        if !winningResults.isEmpty {
            let subject = listText(winningResults.map(\.initials))
            let verb = winningResults.count == 1 ? "wins" : "win"

            return "\(subject) \(verb) with \(targetScore)"
        }

        if leadingResults.isEmpty {
            return "All players bust"
        }

        let closestText = leadingResults
            .map { "\($0.initials) \($0.finalScore)" }

        return listText(closestText)
    }

    private func shareStatus(
        for result: PlayerResult,
        hasWinningResult: Bool,
        leadingResultIDs: Set<UUID>
    ) -> String? {
        if result.didWin {
            return "WIN"
        }

        if result.didBust {
            return "BUST"
        }

        if !hasWinningResult && leadingResultIDs.contains(result.id) {
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
