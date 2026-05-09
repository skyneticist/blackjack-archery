import SwiftUI

struct ContentView: View {
    @State private var appPhase: AppPhase = .playerCountSetup
    @State private var playerCount: Int = 3

    @State private var initialsDrafts: [InitialsDraft] = []
    @State private var gameState = GameState(players: [])
    @State private var latestResult: GameResult?

    var body: some View {
        switch appPhase {
        case .playerCountSetup:
            PlayerCountSetupView(
                playerCount: $playerCount,
                onStart: {
                    prepareInitialsSetup()
                }
            )

        case .initialsSetup:
            InitialsSetupView(
                drafts: $initialsDrafts,
                onBack: {
                    appPhase = .playerCountSetup
                },
                onStart: {
                    startGame()
                }
            )

        case .playing:
            GameView(
                gameState: $gameState,
                onFinishGame: {
                    finishGame()
                },
                onNewGame: {
                    returnToPlayerCountSetup()
                }
            )

        case .results:
            if let latestResult {
                ResultsView(
                    result: latestResult,
                    onNewGame: {
                        returnToPlayerCountSetup()
                    }
                )
            } else {
                ResultsView(
                    result: GameResult(playerResults: []),
                    onNewGame: {
                        returnToPlayerCountSetup()
                    }
                )
            }
        }
    }

    private func prepareInitialsSetup() {
        let safeCount = min(max(playerCount, 1), 8)

        initialsDrafts = (1...safeCount).map { number in
            let characters = placeholderCharacters(for: number)

            return InitialsDraft(characters: characters)
        }

        appPhase = .initialsSetup
    }

    private func startGame() {
        let players = initialsDrafts.enumerated().map { index, draft in
            let initials = normalizedInitials(from: draft, fallbackNumber: index + 1)

            return Player(initials: initials)
        }

        gameState = GameState(players: players)
        latestResult = nil
        appPhase = .playing
    }

    private func finishGame() {
        latestResult = gameState.makeResult()
        appPhase = .results
    }

    private func returnToPlayerCountSetup() {
        gameState = GameState(players: [])
        initialsDrafts = []
        latestResult = nil
        appPhase = .playerCountSetup
    }

    private func placeholderCharacters(for number: Int) -> [String] {
        if number < 10 {
            return ["P", "\(number)", "A"]
        } else {
            return ["P", "X", "A"]
        }
    }

    private func normalizedInitials(
        from draft: InitialsDraft,
        fallbackNumber: Int
    ) -> String {
        let initials = draft.initials
            .uppercased()
            .filter { $0.isLetter || $0.isNumber }

        if initials.isEmpty {
            return "P\(fallbackNumber)"
        }

        return String(initials.prefix(3))
    }
}
