# BlackJack Archery

BlackJack Archery is a compact watchOS scoring app for an archery game played to
21. It is designed around quick one-handed scoring on a 42 mm Apple Watch: choose
the number of players, enter initials, score each player with plus/minus controls,
finish the game, and share the final results as readable plain text.

The app intentionally avoids large decorative layouts. Most controls use fixed
dimensions, plain SwiftUI button styles, and stable view slots so the interface
does not jump around on small watch displays.

## Current Status

- Platform: watchOS SwiftUI app
- Primary target size: 42 mm Apple Watch
- Player count: 1 to 8 players
- Target score: 21
- Main interaction methods: direct buttons and Digital Crown
- Result sharing: plain-text scorecard from the finished results screen
- Cast/AirPlay: not implemented; the app does not currently have a true receiver
  or media route workflow

## Screenshots

Screenshots are not checked in yet. Add exported screenshots later under
`docs/images/` using the names below, then replace this table with inline image
previews if desired.

| View | Suggested File | Purpose |
| --- | --- | --- |
| Player count | `docs/images/player-count.png` | Shows the opening player-count selector. |
| Initials entry | `docs/images/initials-entry.png` | Shows character selection and player navigation. |
| Score entry | `docs/images/score-entry.png` | Shows the active player card and score buttons. |
| Score options | `docs/images/score-options.png` | Shows the `Rules / Reset / New / Back` options tray. |
| Results | `docs/images/results.png` | Shows the finished score ranking and share controls. |
| Shared text | `docs/images/shared-text.png` | Shows the SMS/Message result formatting. |

I was not able to capture live screenshots in this environment because full
simulator-backed Xcode builds are currently blocked by missing local simulator
runtimes.

## Game Flow

The app has four high-level phases:

1. Player count setup
2. Initials setup
3. Active scoring
4. Finished results

`ContentView` owns the current `AppPhase` and moves the app through those
screens. It also creates the player list, resets game state, and stores the
latest finished result.

### Player Count

`PlayerCountSetupView` lets the user choose between 1 and 8 players. It supports
both direct plus/minus buttons and Digital Crown rotation. The current count is
large, centered, and colored with the app's muted teal accent.

### Initials Entry

`InitialsSetupView` collects three-character player initials. The Digital Crown
cycles through the supported character set:

```text
A-Z, 0-9
```

The screen tracks the current player and current character slot. Buttons allow
moving between character slots, moving back, and advancing to the next player or
starting the game.

### Score Entry

`GameView` is the main scoring screen. It shows one active player card at a time
and uses the Digital Crown to move between players. The active player card shows:

- Initials
- Player position
- Status badge
- Current score
- Plus/minus score buttons
- Progress toward 21
- Page dots for player position

The bottom control area is a fixed-height slot. It swaps between:

```text
Finish / More
```

and:

```text
Rules / Reset / New / Back
```

The fixed slot prevents the player card from shifting when the options tray is
opened. The `Rules` action opens a compact scrollable rules reference sized for
the same 42 mm-first layout.

### Results

`ResultsView` shows the final ranked score list and exposes sharing for the final
result. The winner text near the top uses a muted green accent. The results view
caches derived display data when it is created because a finished result is
immutable for that screen.

## Blackjack Archery 21 Rules

There does not appear to be one universal governing-body rulebook for
Blackjack/21 archery. Published club, camp, and activity-guide variants all
follow the same core idea: score as close to 21 as possible without going over.
This app uses the target-face scoring variant below as its canonical rule set.

Reference variants:

- [Randwick Archery Club: Blackjack](https://www.sporty.co.nz/randwickarchery/resources-2/archery-games)
- [Aim4sport: Blackjack](https://aim4sport.com/archery-games-a-e/)
- [Girl Scouts of Citrus Council Target Sports Programming Guide](https://www.gscb.org/content/dam/gscb-redesign/documents/campoutdoor/Target%20Sports%20Programming%20Guide.pdf)

### App Rule Set

The target score is defined by `Player.targetScore` and is currently `21`.

The app treats one game as a single running race to 21:

- A player wins by landing exactly on 21.
- A player busts when their score exceeds 21.
- If no one hits 21, the results screen highlights the closest non-bust score.
- If all players bust, the result is reported as all bust.
- Scores can be entered manually using the plus and minus controls, which makes
  the app usable with any target face, house scoring system, or practice drill.

Result sorting prioritizes:

1. Exact winners
2. Non-bust players
3. Higher scores
4. Bust players after eligible players

### Common Target-Face Variant

This is the variant most closely aligned with the current app:

1. Archers shoot arrows into a standard scoring target.
2. Each arrow contributes the value of the scoring ring or scoring method being
   used by the group.
3. Archers continue trying to build a total of 21.
4. An archer who goes over 21 busts.
5. An archer who lands exactly on 21 wins the game or end.
6. If no archer lands exactly on 21, the highest score under 21 wins.
7. If all archers bust, the end can be replayed or recorded as all bust.

Optional variations found in published rules:

- Limit each archer to a fixed number of arrows per end.
- Let archers stop shooting once they are satisfied with their score.
- Play multiple ends and award match points to the winner of each end.
- Treat an especially strong shot pattern, such as two yellows, as an automatic
  21 for beginner-friendly play.

### Playing-Card Target Variant

Some versions attach playing cards to the target instead of using normal scoring
rings:

1. Cards are pinned or clipped to the target face.
2. Each archer shoots at the cards.
3. Number cards score their face value.
4. Jacks, queens, and kings score 10.
5. Aces score 1 or 11, at the archer's choice.
6. The closest total to 21 without going over wins.

This app does not currently model individual cards or aces; use manual score
entry if playing this variation.

## Shared Results Format

Finished results are shared as plain text so the output survives SMS, Messages,
email, and other share targets without relying on rich formatting.

Example:

```text
Archery 21

Winner
JH wins with 21

Target: 21
Players: 3

Scorecard
1. JH    21   WIN
2. AM    18
3. ZK    24   BUST
```

The share format is generated by `GameResult.summaryText`.

## Project Structure

### App Shell

| File | Responsibility |
| --- | --- |
| `BlackJack_ArcheryApp.swift` | watchOS app entry point. |
| `ContentView.swift` | Top-level state machine and screen routing. |
| `AppPhase.swift` | App phase enum: setup, initials, playing, results. |

### Setup Screens

| File | Responsibility |
| --- | --- |
| `PlayerCountSetupView.swift` | Selects the number of players with buttons and Digital Crown. |
| `InitialsSetupView.swift` | Captures player initials with Digital Crown character selection. |
| `InitialsDraft.swift` | Mutable initials draft model used before players are created. |

### Active Game UI

| File | Responsibility |
| --- | --- |
| `GameView.swift` | Main score-entry screen, player selection, finish/reset/new controls. |
| `PlayerScoreCard.swift` | Active player card layout and progress display. |
| `RulesView.swift` | Compact in-game Blackjack Archery 21 rules reference. |
| `ScoreButton.swift` | Circular plus/minus score buttons. |
| `StatusBadge.swift` | Compact status label for playing/exact/bust states. |
| `PlayerPageDots.swift` | Player position indicator dots. |
| `EmptyGameView.swift` | Fallback state when no players are available. |

### Results UI

| File | Responsibility |
| --- | --- |
| `ResultsView.swift` | Finished results screen and final share action. |
| `ResultRow.swift` | Individual ranked result row. |

### Domain Models

| File | Responsibility |
| --- | --- |
| `Player.swift` | Player identity, score, target score, and status derivation. |
| `PlayerStatus.swift` | Playing/exact/bust status metadata. |
| `PlayerScore.swift` | Score value wrapper. |
| `PlayerResult.swift` | Immutable per-player result snapshot. |
| `GameState.swift` | Active game state, selected player, score mutations, result creation. |
| `GameResult.swift` | Finished result sorting, outcome text, and share text formatting. |

### Tests And Assets

| Path | Responsibility |
| --- | --- |
| `BlackJack Archery Watch AppTests/` | Unit test target placeholder. |
| `BlackJack Archery Watch AppUITests/` | UI test target placeholder. |
| `Assets.xcassets/` | App icons, accent color, and asset catalog metadata. |

## Design Principles

- Optimize for a 42 mm watch first.
- Prefer compact controls with predictable fixed dimensions.
- Keep tap targets large enough for real watch use.
- Avoid UI cards inside other UI cards.
- Avoid marketing-style or decorative layout patterns.
- Keep the color palette muted: white, gray, red for bust, yellow for exact,
  muted teal/green for accents.
- Use the Digital Crown where it reduces tapping effort.
- Keep the bottom control area stable so the primary content does not jump.

## Performance And Stability Notes

- Results screen data is derived once in `ResultsView.init` because finished
  results are immutable for that screen.
- `ResultRow` is `Equatable`, allowing SwiftUI to skip unchanged row internals
  during reveal/state updates.
- `InitialsSetupView` stores the allowed character table statically so it is not
  rebuilt per view instance.
- `GameResult` avoids unnecessary temporary arrays in closest-score calculation
  and share-text formatting.
- Dense watch controls use `.buttonStyle(.plain)` with custom labels to avoid
  system bridged button-bar constraint warnings and unpredictable hit targets.
- `digitalCrownRotation` owns detent haptics; crown-change callbacks should not
  also fire manual click haptics.

## Known Limitations

- There is no true cast/AirPlay score display. watchOS route-picking APIs are
  media-oriented, and this app does not currently have a second-screen receiver.
- Full Xcode builds in this development environment currently fail at the
  companion asset-catalog step when simulator runtimes are unavailable.
- Tests are currently placeholders and should be expanded around game rules,
  result sorting, and share text formatting.

## Verification

Targeted Swift type-check:

```sh
xcrun --sdk watchos swiftc -typecheck 'BlackJack Archery Watch App/'*.swift -target arm64-apple-watchos11.0 -parse-as-library -module-cache-path /private/tmp/blackjack-swift-module-cache
```

Whitespace and patch sanity:

```sh
git diff --check
git diff --cached --check
```

Full Xcode build:

```sh
xcodebuild -quiet -project 'BlackJack Archery.xcodeproj' -scheme 'BlackJack Archery Watch App' -configuration Debug -destination 'generic/platform=watchOS' -derivedDataPath /private/tmp/blackjack-archery-derived CODE_SIGNING_ALLOWED=NO build
```

## Suggested Next Test Coverage

- Player status at scores below, equal to, and above 21.
- Score increment/decrement boundaries.
- Result sorting with winners, closest non-bust players, ties, and all-bust games.
- Plain-text share formatting for single winner, multiple winners, closest
  non-winner, and all-bust outcomes.
- State transitions from setup to initials to active game to results.
